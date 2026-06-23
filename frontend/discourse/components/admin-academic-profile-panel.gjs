/** @ts-check */
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { fn } from "@ember/helper";
import { ajax } from "discourse/lib/ajax";
import DButton from "discourse/components/d-button";
import GroupChooser from "select-kit/components/group-chooser";

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
    
    // Her bir ünvan için mevcut grup dizisini oluştur
    this.titleMappings = titles.map(title => ({
      title: title,
      group_ids: mappings[title] || []
    }));
  }

  @action
  updateGroups(mapping, newGroupIds) {
    mapping.group_ids = newGroupIds;
    // Reaktiviteyi tetiklemek için diziyi yenile
    this.titleMappings = [...this.titleMappings];
  }

  @action
  async triggerSync() {
    this.isSyncing = true;
    this.syncSuccess = false;

    // Backend'in beklediği Hash { "Profesör": [1,2], "Doçent": [3] } formatına çevir
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
      // Hatalar sistem tarafından toast olarak gösterilir
    } finally {
      this.isSyncing = false;
    }
  }

  <template>
    <div class="admin-academic-profile-panel-container" style="max-width: 800px; padding: 20px;">
      <h1>Akademik Profil ve Grup Otomasyonu</h1>
      
      <div class="panel-info-box" style="margin-bottom: 20px; padding: 15px; background: var(--secondary-very-high);">
        <p>Aşağıdaki listedeki ünvanlar <strong>bekcan_academic_titles</strong> site ayarından çekilmektedir.</p>
        <p>Hangi ünvan seçildiğinde kullanıcının hangi gruplara otomatik ekleneceğini belirleyin. Bir ünvan sınırsız sayıda gruba eşlenebilir.</p>
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
          @label="Ayarları ve Grupları Veritabanına Eşitle (Sync)"
          @disabled={{this.isSyncing}}
          class="btn-primary"
        />

        {{if this.syncSuccess}}
          <div class="sync-success-alert" style="margin-top: 10px; color: var(--success);">
            <p>✓ Ayarlar başarıyla okundu ve grup eşleşmeleri (PluginStore) güncellendi!</p>
          </div>
        {{/if}}
      </div>
    </div>
  </template>
}