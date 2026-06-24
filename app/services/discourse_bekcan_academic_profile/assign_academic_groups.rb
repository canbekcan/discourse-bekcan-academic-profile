# frozen_string_literal: true

module DiscourseBekcanAcademicProfile
  class AssignAcademicGroups
    # Functional Service Object architecture
    def self.call(user:, new_group_ids:)
      new(user: user, new_group_ids: new_group_ids).call
    end

    def initialize(user:, new_group_ids:)
      @user = user
      @new_group_ids = Array(new_group_ids).map(&:to_i).reject(&:zero?)
    end

    def call
      # Redis-backed distributed lock prevents concurrent assignment for the same user
      DistributedMutex.synchronize("assign_academic_groups_#{@user.id}") do
        ActiveRecord::Base.transaction do
          process_group_assignment!
        end
      end
    rescue StandardError => e
      Discourse.warn_exception(e, message: "BekcanAcademicProfile: Failed to assign groups for User ID #{@user.id}")
      false
    end

    private

    def process_group_assignment!
      current_group_ids = @user.groups.where(automatic: false).pluck(:id)
      
      groups_to_add = @new_group_ids - current_group_ids
      groups_to_remove = current_group_ids - @new_group_ids

      # Remove obsolete academic groups
      if groups_to_remove.any?
        GroupUser.where(user_id: @user.id, group_id: groups_to_remove).destroy_all
      end

      # Add new academic groups safely
      groups_to_add.each do |group_id|
        group = Group.find_by(id: group_id)
        next unless group && !group.automatic

        group.add(@user)
      end

      true
    end
  end
end