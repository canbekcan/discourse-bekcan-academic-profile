module ::DiscourseBekcanAcademicProfile
  class UserFieldBuilder
    def call
      # 'academic_title' alanını oluştur, description kısmına i18n anahtarı yaz
      field = UserField.find_or_initialize_by(name: "academic_title")
      if field.new_record?
        field.field_type = "dropdown"
        field.description = "user.user_fields.academic_title" # Dil dosyasından çevirir
        field.editable = true
        field.show_on_profile = true
        field.save!
      end
    end
  end
end