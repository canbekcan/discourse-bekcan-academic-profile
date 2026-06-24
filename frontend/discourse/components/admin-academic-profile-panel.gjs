/** @ts-check */
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { fn } from "@ember/helper";
import concat from "@ember/helper/concat";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import Form from "discourse/components/form";
import DButton from "discourse/components/d-button";
import GroupChooser from "select-kit/components/group-chooser";
import i18n from "discourse-common/helpers/i18n";

export default class AdminAcademicProfilePanel extends Component {
  @tracked titleMappings = [];
  groups = [];

  constructor() {
    super(...arguments);
    const titles = this.args.model.titles || [];
    const mappings = this.args.model.mappings || {};
    this.groups = this.args.model.groups || [];

    // Retain machine keys in JS. Let the template handle live translations.
    this.titleMappings = titles.map((titleKey) => ({
      key: titleKey,
      group_ids: mappings[titleKey] || [],
    }));
  }

  @action
  updateGroups(mapping, newGroupIds) {
    mapping.group_ids = newGroupIds;
    // Trigger Ember reactivity for tracked array elements
    this.titleMappings = [...this.titleMappings];
  }

  @action
  async saveSettings() {
    const payload = {};
    this.titleMappings.forEach((m) => (payload[m.key] = m.group_ids));

    try {
      await ajax("/admin/plugins/academic-profile/sync", {
        type: "POST",
        data: { mappings: payload },
      });
    } catch (error) {
      popupAjaxError(error);
      throw error; // Throwing ensures FormKit resets its loading state
    }
  }

  <template>
    <div class="academic-profile-admin">
      <h3>{{i18n "js.bekcan_academic_profile.admin.panel_title"}}</h3>

      {{!-- Exclusively utilizing FormKit to manage submission state --}}
      <Form @onSubmit={{this.saveSettings}} as |f|>
        {{#each this.titleMappings as |m|}}
          <div class="academic-profile-mapping-row">
            <label class="mapping-label">
              {{!-- Dynamic translation using nested helpers --}}
              {{i18n (concat "js.bekcan_academic_profile.titles." m.key)}}
            </label>
            <GroupChooser
              @content={{this.groups}}
              @value={{m.group_ids}}
              @onChange={{fn this.updateGroups m}}
              @multiple={{true}}
            />
          </div>
        {{/each}}

        <div class="academic-profile-actions">
          <DButton
            @action={{f.submit}}
            @label={{i18n "js.bekcan_academic_profile.admin.sync_button"}}
            @isLoading={{f.isSubmitting}}
            class="btn-primary"
          />
        </div>
      </Form>
    </div>
  </template>
}