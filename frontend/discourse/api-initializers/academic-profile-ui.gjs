/** @ts-check */
import { withPluginApi } from "discourse/lib/plugin-api";
import I18n from "discourse-i18n";

export default {
  name: "academic-profile-ui",
  initialize() {
    withPluginApi("1.25.0", (api) => {
      api.modifyClass("component:user-custom-fields", {
        pluginId: "discourse-bekcan-academic-profile",
        
        // Unvan çevirilerini otomatik yükle
        get academicTitleOptions() {
           const field = this.userFields.findBy("name", "academic_title");
           if (!field) return [];
           return field.options.map(opt => ({
             name: I18n.t(`academic_profile.titles.${opt.value}`, { defaultValue: opt.value }),
             value: opt.value
           }));
        }
      });
    });
  }
};