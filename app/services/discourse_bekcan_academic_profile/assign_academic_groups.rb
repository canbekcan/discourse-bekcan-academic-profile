module ::DiscourseBekcanAcademicProfile
  class AssignAcademicGroups
    def call(user:)
      return unless SiteSetting.bekcan_academic_profile_enabled

      title_field = UserField.find_by(name: "academic_title")
      return unless title_field

      user_title = user.custom_fields["user_field_#{title_field.id}"]
      mappings = PluginStore.get("bekcan_academic", "group_mappings") || {}
      
      # Kullanıcının şu anki ünvanına ait hedef grup ID'leri
      target_group_ids = mappings[user_title] || []
      
      # Eklentinin yönettiği TÜM grup ID'leri havuzu
      all_managed_group_ids = mappings.values.flatten.uniq

      groups_to_add = Group.where(id: target_group_ids)
      # Hedefte olmayan ama bizim yönettiğimiz diğer gruplar (kullanıcıdan silinmesi gerekenler)
      groups_to_remove = Group.where(id: all_managed_group_ids - target_group_ids)

      DistributedMutex.synchronize("assign_academic_groups_#{user.id}") do
        ActiveRecord::Base.transaction do
          groups_to_add.each do |g| 
            g.add(user) unless g.users.include?(user)
          end
          
          groups_to_remove.each do |g| 
            g.remove(user) if g.users.include?(user)
          end
        end
      end
    rescue StandardError => e
      Discourse.warn_exception(e, message: "Academic Group Assignment Failed for user: #{user.id}")
    end
  end
end