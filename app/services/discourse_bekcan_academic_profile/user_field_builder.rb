module ::DiscourseBekcanAcademicProfile
  class UserFieldBuilder
    
    # Türkiye Cumhuriyeti Yükseköğretim mevzuatına uygun tüm akademik ünvanlar
    ACADEMIC_TITLES = [
      "Profesör (Prof. Dr.)",
      "Doçent (Doç. Dr.)",
      "Doktor Öğretim Üyesi (Dr. Öğr. Üyesi)",
      "Öğretim Görevlisi (Öğr. Gör.)",
      "Araştırma Görevlisi (Arş. Gör.)",
      "Uzman Doktor (Uzm. Dr.)",
      "Doktora Öğrencisi / Adayı",
      "Yüksek Lisans Mezunu / Öğrencisi"
    ].freeze

    def call
      return unless SiteSetting.bekcan_academic_profile_enabled

      # Çoklu sunucu/proses ortamlarında eşzamanlı (race condition) kayıt açılmasını engellemek için kilit mekanizması
      DistributedMutex.synchronize("bekcan_academic_title_field_init") do
        ActiveRecord::Base.transaction do
          
          # ID bağımsız aramayı alanın sistem adına (name) göre yapıyoruz
          title_field = UserField.find_or_create_by!(name: "academic_title") do |f|
            f.field_type = "dropdown"
            f.description = "Akademik Ünvanınız"
            f.required = false      # Kayıtta zorunlu olmasın (isteğe bağlı)
            f.editable = true       # KRİTİK: Üyeler profillerinden kendileri değiştirebilir
            f.show_on_profile = true # Profil sayfasında gösterilsin
            f.show_on_user_card = true # Kullanıcı kartında kartvizit gibi gösterilsin
          end

          # Dropdown seçeneklerini senkronize etme adımı
          ACADEMIC_TITLES.each do |title_name|
            UserFieldOption.find_or_create_by!(
              user_field_id: title_field.id,
              value: title_name
            )
          end
          
        end
      end
    rescue StandardError => e
      Discourse.warn_exception(e, message: "Academic title user-field sync failed.")
    end
  end
end