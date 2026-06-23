module ::DiscourseBekcanAcademicProfile
  class AssignProfessorGroup
    # Fonksiyonel akış: Parametre Kontrolü -> Kilit (Lock) -> Transaction -> Model İşlemi
    def call(user:)
      return unless SiteSetting.bekcan_academic_profile_enabled
      return if SiteSetting.professor_auto_group_id <= 0

      # Kullanıcının academic_title alanını bul
      title_field = UserField.find_by(name: "academic_title")
      return unless title_field

      user_title = user.custom_fields["user_field_#{title_field.id}"]
      target_group = Group.find_by(id: SiteSetting.professor_auto_group_id)
      
      return unless target_group

      # Eşzamanlı yarış koşullarını (Race Conditions) engellemek için DistributedMutex kullanımı
      DistributedMutex.synchronize("assign_prof_group_#{user.id}") do
        ActiveRecord::Base.transaction do
          if user_title == "Profesör"
            target_group.add(user) unless target_group.users.include?(user)
          else
            target_group.remove(user) if target_group.users.include?(user)
          end
        end
      end
    rescue StandardError => e
      Discourse.warn_exception(e, message: "Academic Profile Group Assignment Failed for user: #{user.id}")
    end
  end
end