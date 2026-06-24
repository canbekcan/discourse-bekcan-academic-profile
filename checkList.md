[x] Problem 1: Glimmer Strict Mode Violation (Legacy .hbs templates removed)
[x] Problem 2: Missing JavaScript Type Validations (/ @ts-check */ and Glint ready)
[x] Problem 3: Concurrency Flaws in Group Assignment (Isolated via DistributedMutex and DB transactions)
[x] Problem 4: UserField Database Corruption Risk (Immutable machine-keys used via find_or_initialize_by)
[x] Problem 5: Zeitwerk Engine Autoloading & Route Collisions (Engine isolated to lib/ and mounted correctly)
[x] Problem 6: Unpinned Backward Compatibility (Hard guarded via minimum_discourse_version header)
[x] Problem 7: Invisible Ember Site Settings (Exposed via client: true attribute block)

###
[x] Problem 1: Empty Zeitwerk Engine Configuration (Core)
File: lib/discourse_bekcan_academic_profile/engine.rb
Status: The file exists but is empty. Without a valid Rails::Engine declaration and isolate_namespace, Zeitwerk autoloading will fail, crashing the backend.
[x] Problem 2: Blank Site Settings (Core/Frontend)
File: config/settings.yml
Status: The file is empty. Your site settings (e.g., bekcan_academic_profile_enabled) are missing, meaning the Ember frontend cannot read them (client: true), and the plugin cannot be toggled via the Discourse admin panel.
[ ] Problem 3: Unimplemented Admin Controllers (Backend)
File: app/controllers/discourse_bekcan_academic_profile/academic_profile_controller.rb
Status: The file is empty. The POST /sync API endpoint required by the frontend <Form> submission does not have a backend controller to process the payload.
[ ] Problem 4: Unpopulated Backward Compatibility (DevOps)
File: .discourse-compatibility
Status: The file is empty. You must either provide legacy commit hashes for older Discourse versions (e.g., < 3.2.0) or explicitly lock the version using # minimum_discourse_version: 3.2.0 inside plugin.rb.
[ ] Problem 5: Incomplete JavaScript Route Maps (Frontend)
Files: frontend/discourse/admin-route-map.js & frontend/discourse/routes/admin-plugins-academic-profile.js
Status: These files are empty. The Ember router does not know how to map the admin/plugins/academic-profile URL to your newly created Glimmer component (admin-academic-profile-panel.gjs).
[ ] Problem 6: Missing Translation Dictionary Keys (Localization)
Files: config/locales/client.en.yml & config/locales/server.en.yml
Status: While the files exist, we must ensure they contain the exact keys referenced by the Service Objects (academic_title descriptions) and the frontend Glimmer UI (js.bekcan_academic_profile.admin.panel_title).