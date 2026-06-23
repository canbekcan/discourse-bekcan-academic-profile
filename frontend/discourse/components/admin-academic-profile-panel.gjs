/** @ts-check */
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import DButton from "discourse/components/d-button";

export default class AdminAcademicProfilePanel extends Component {
  @tracked isSyncing = false;
  @tracked syncSuccess = false;

  @action
  async triggerSync() {
    this.isSyncing = true;
    this.syncSuccess = false;

    try {
      // Backend API'ye el ile tetikleme isteği gönderir
      await ajax("/admin/plugins/academic-profile/sync", { type: "POST" });
      this.syncSuccess = true;
    } catch (error) {
      // Hatalar Discourse Ajax katmanı tarafından global bildirim (Toast) ile ele alınır
    } finally {
      this.isSyncing = false;
    }
  }

  <template>
    <div class="admin-academic-profile-panel-container">
      <h1>Akademik Profil Yönetim Paneli</h1>
      
      <div class="panel-info-box">
        <p>
          Sistemdeki akademik ünvan dropdown menü seçenekleri, 
          <strong>Site Ayarları > Plugins > bekcan_academic_titles</strong> 
          alanındaki verilerle doğrudan beslenmektedir.
        </p>
        <p>
          Panelden ünvan ekleyip sildikten sonra, değişikliklerin mevcut kullanıcıların profil 
          alanlarına anlık olarak yansıması için aşağıdaki butonu kullanarak veritabanı senkronizasyonunu başlatabilirsiniz.
        </p>
      </div>

      <div class="panel-action-row">
        <DButton
          @action={{this.triggerSync}}
          @icon="sync"
          @label="Değişiklikleri Veritabanına Eşitle (Sync)"
          @disabled={{this.isSyncing}}
          class="btn-primary"
        />

        {{if this.syncSuccess}}
          <div class="sync-success-alert">
            <p>✓ Ayarlar başarıyla okundu ve kullanıcı profil alanları (UserFieldOptions) güncellendi!</p>
          </div>
        {{/if}}
      </div>
    </div>
  </template>
}