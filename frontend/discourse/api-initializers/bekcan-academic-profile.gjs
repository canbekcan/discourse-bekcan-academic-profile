/** @ts-check */
import { withPluginApi } from "discourse/lib/plugin-api";
import { tracked } from "@glimmer/tracking";

export default {
  name: "bekcan-academic-profile-ui",
  
  initialize() {
    withPluginApi("1.25.0", (api) => {
      // CustomField form render yapısını hedef alan Glimmer modifikasyonu
      api.modifyClass("component:user-custom-fields", {
        pluginId: "discourse-bekcan-academic-profile",

        @tracked currentAcademicField: null,

        // Alanlar değiştiğinde tetiklenen observer yapısını simüle etmek için setter/getter
        didReceiveAttrs() {
          this._super(...arguments);
          this._ensureAcademicTitleState();
        },

        _ensureAcademicTitleState() {
          if (!this.userFields) return;
          
          const academicField = this.userFields.findBy("name", "academic_title");
          if (academicField) {
            // Alanın arayüzde 'editable' (düzenlenebilir) olduğu client state üzerinde de onaylanır
            academicField.set("editable", true);
          }
        },

        actions: {
          updateCustomField(field, value) {
            this._super(field, value);
            
            // Eğer değiştirilen alan academic_field ise, durumu yakala ve alt alanı filtrele
            if (field.name === "academic_field") {
              this.currentAcademicField = value;
              this.filterDisciplines();
            }
          }
        },

        filterDisciplines() {
          const disciplinesField = this.userFields.findBy("name", "scientific_disciplines");
          const academicField = this.userFields.findBy("name", "academic_field");
          
          if (!disciplinesField || !academicField) return;

          const selectedField = this.currentAcademicField || this.model.custom_fields[`user_field_${academicField.id}`];

          // DOM opsiyon manipülasyonu - İlgili kategoriye göre seçenekleri kısıtla
          let allowedOptions = [];
          if (selectedField === "Temel Bilimler") {
            allowedOptions = ["Fizik", "Kimya", "Biyoloji"];
          } else if (selectedField === "Sosyal Bilimler") {
            allowedOptions = ["Tarih", "Sosyoloji"];
          } else {
            allowedOptions = ["Fizik", "Kimya", "Biyoloji", "Tarih", "Sosyoloji"]; // Varsayılan hepsi
          }

          // Çoklu seçim (Multi-select) içeriğini dinamik olarak sınırlandırıyoruz
          disciplinesField.set("options", allowedOptions);
        }
      });
    });
  }
};