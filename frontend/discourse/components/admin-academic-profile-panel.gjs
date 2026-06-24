import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { fn } from "@ember/helper";
import { ajax } from "discourse/lib/ajax";
import DButton from "discourse/components/d-button";
import GroupChooser from "select-kit/components/group-chooser";
import I18n from "discourse-i18n";

export default class AdminAcademicProfilePanel extends Component {
  @tracked isSyncing = false;
  @tracked syncSuccess = false;
  titleMappings = [];

  constructor() {
    super(...arguments);
    const titles = this.args.model.titles || [];
    const mappings = this.args.model.mappings || {};
    this.groups = this.args.model.groups || [];
    
    this.titleMappings = titles.map(titleKey => ({
      key: titleKey,
      displayName: I18n.t(`js.bekcan_academic_profile.titles.${titleKey}`, { defaultValue: titleKey }),
      group_ids: mappings[titleKey] || []
    }));
  }

  @action updateGroups(mapping, newGroupIds) {
    mapping.group_ids = newGroupIds;
  }

  @action async triggerSync() {
    this.isSyncing = true;
    const payload = {};
    this.titleMappings.forEach(m => payload[m.key] = m.group_ids);
    await ajax("/admin/plugins/academic-profile/sync", { type: "POST", data: { mappings: payload } });
    this.syncSuccess = true;
    this.isSyncing = false;
  }

  <template>
    <div class="academic-profile-admin">
      <h3>{{I18n "js.bekcan_academic_profile.admin.panel_title"}}</h3>
      {{#each this.titleMappings as |m|}}
        <div class="mapping" style="margin-bottom: 20px;">
          <label style="font-weight: bold;">{{m.displayName}}</label>
          <GroupChooser @content={{this.groups}} @value={{m.group_ids}} @onChange={{fn this.updateGroups m}} @multiple={{true}} />
        </div>
      {{/each}}
      <DButton @action={{this.triggerSync}} @label={{I18n "js.bekcan_academic_profile.admin.sync_button"}} @disabled={{this.isSyncing}} />
    </div>
  </template>
}