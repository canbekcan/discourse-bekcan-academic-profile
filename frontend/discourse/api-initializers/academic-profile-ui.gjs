/** @ts-check */
import { withPluginApi } from "discourse/lib/plugin-api";
import I18n from "discourse-i18n";

export default {
  name: "bekcan-academic-title-profile-sync",

  initialize() {
    withPluginApi("1.25.0", (api) => {
      api.modifyClass("component:user-custom-fields", {
        pluginId: "discourse-bekcan-academic-profile",

        didReceiveAttrs() {
          this._super(...arguments);
          if (!this.userFields) return;

          this.userFields.forEach(f => {
            if (f.name === "academic_title") {
              f.set("name", I18n.t("bekcan_academic_profile.user_fields.academic_title_name"));
              f.set("description", I18n.t("bekcan_academic_profile.user_fields.academic_title_desc"));
              
              // Veritabanındaki 'prof' gibi kodları ekranda 'Profesör' göstermek için objeye çeviriyoruz.
              // SelectKit (ComboBox) name alanını ekranda gösterir, value kısmını arka uça yollar.
              if (f.options && typeof f.options[0] === "string") {
                f.set("options", f.options.map(opt => {
                  return {
                    name: I18n.t(`bekcan_academic_profile.titles.${opt}`, { defaultValue: opt }),
                    value: opt
                  };
                }));
              }
            } else if (f.name === "academic_field") {
              f.set("name", I18n.t("bekcan_academic_profile.user_fields.academic_field_name"));
              f.set("description", I18n.t("bekcan_academic_profile.user_fields.academic_field_desc"));
            } else if (f.name === "scientific_disciplines") {
              f.set("name", I18n.t("bekcan_academic_profile.user_fields.scientific_disciplines_name"));
              f.set("description", I18n.t("bekcan_academic_profile.user_fields.scientific_disciplines_desc"));
            }
          });
        }
      });
    });
  }
};