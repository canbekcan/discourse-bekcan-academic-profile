/** @ts-check */
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { fn } from "@ember/helper";
import { ajax } from "discourse/lib/ajax";
import DButton from "discourse/components/d-button";
import GroupChooser from "select-kit/components/group-chooser";
import I18n from "discourse-i18n";
import { htmlSafe } from "@ember/template";

export default class AdminAcademicProfilePanel extends Component {
  @tracked isSyncing = false;
  @tracked syncSuccess = false;
  @tracked titleMappings = [];

  constructor() {
    super(...arguments);
    this.initializeMappings();
  }

  initializeMappings() {
    const titles = this.args.model.titles || [];
    const mappings = this.args.model.mappings || {};
    
    this.titleMappings = titles.map(title => ({
      title: title,
      group_ids: mappings[title] || []
    }));
  }

  @action
  updateGroups(mapping, newGroupIds) {
    mapping.group_ids = newGroupIds;
    this.titleMappings = [...this.titleMappings];
  }

  @action
  async triggerSync() {
    this.isSyncing = true;
    this.syncSuccess = false;

    const payloadMappings = {};
    this.titleMappings.forEach(m => {
      payloadMappings[m.title] = m.group_ids;
    });

    try {
      await ajax("/admin/plugins/academic-profile/sync", { 
        type: "POST",
        data: { mappings: payloadMappings }
      });
      this.syncSuccess = true;
    } catch (error) {
      // discourse/lib/ajax handles toast errors automatically
    } finally {
      this.isSyncing = false;
    }
  }

  <template>
    <div class="admin-academic-profile-panel-container" style="max-width: 800px; padding: 20px;">
      <h1>{{I18n "bekcan_academic_profile.admin.panel_title"}}</h1>
      
      <div class="panel-info-box" style="margin-bottom: 20px; padding: 15px; background: var(--secondary-very-high);">
        <p>{{htmlSafe (I18n "bekcan_academic_profile.admin.info_html")}}</p>
      </div>

      <div class="mappings-list" style="margin-bottom: 30px;">
        {{#each this.titleMappings as |mapping|}}
          <div class="mapping-row" style="margin-bottom: 15px; display: flex; flex-direction: column;">
            <label style="font-weight: bold; margin-bottom: 5px;">{{mapping.title}}</label>
            
            <GroupChooser 
              @values={{mapping.group_ids}}
              @onChange={{fn this.updateGroups mapping}}
              @multiple={{true}}
            />
          </div>
        {{/each}}
      </div>

      <div class="panel-action-row">
        <DButton
          @action={{this.triggerSync}}
          @icon="sync"
          @label={{I18n "bekcan_academic_profile.admin.sync_button"}}
          @disabled={{this.isSyncing}}
          class="btn-primary"
        />

        {{if this.syncSuccess}}
          <div class="sync-success-alert" style="margin-top: 10px; color: var(--success);">
            <p>{{I18n "bekcan_academic_profile.admin.sync_success"}}</p>
          </div>
        {{/if}}
      </div>
    </div>
  </template>
}