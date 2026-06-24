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
[x] Problem 3: Unimplemented Admin Controllers (Backend)
File: app/controllers/discourse_bekcan_academic_profile/academic_profile_controller.rb
Status: The file is empty. The POST /sync API endpoint required by the frontend <Form> submission does not have a backend controller to process the payload.
[x] Problem 4: Incomplete Backward Compatibility (DevOps)
File: .discourse-compatibility
Status: The file has the correct comments but lacks the actual legacy commit hash mapping. You must either provide a valid legacy commit hash (e.g., < 3.2.0: abc123def456) or, if this is a new plugin, enforce # minimum_discourse_version: 3.2.0 inside plugin.rb and delete the .discourse-compatibility file.
[x] Problem 5: Incomplete JavaScript Route Maps & Type Hinting (Frontend)
Files: frontend/discourse/admin-route-map.js & frontend/discourse/routes/admin-plugins-academic-profile.js
Status: The files exist and have basic Ember routing, but they lack the mandatory / @ts-check */ directive for Glint type validation. Additionally, the route map must precisely map the admin dashboard URL to your specific Glimmer component.
[x] Problem 6: Missing Translation Dictionary Keys (Localization)
Files: config/locales/client.en.yml & config/locales/server.en.yml
Status: The files lack the exact I18n keys referenced by the backend Service Objects (bekcan_academic_profile.user_field.description) and the frontend Glimmer UI (js.bekcan_academic_profile.admin.panel_title, js.bekcan_academic_profile.title).

###

[x] Problem 1: Missing Backend API Logic
Status: academic_profile_controller.rb is empty.
Task: Implement the index (for data retrieval) and sync (for payload saving) actions.
[x] Problem 2: Unmapped Engine Routes
Status: Missing route draw configuration in engine.rb or plugin.rb.
Task: Map /data and /sync to the AcademicProfileController.
[x] Problem 3: Localization/I18n Consistency
Status: Verification required.
Task: Ensure YAML keys used in admin-academic-profile-panel.gjs match the backend string formatting.
[x] Problem 4: DevOps/Compatibility Verification
Status: Pending final verification.
Task: Verify the minimum_discourse_version header in plugin.rb.
[x] Problem 5: Incomplete Frontend Route Infrastructure
Task: Implement admin-route-map.js and routes/admin-plugins-academic-profile.js with TypeScript/Glint / @ts-check */ headers.
[x] Problem 6: Localization & Translation Compliance
Task: Populate config/locales/client.en.yml and server.en.yml with the mandatory business logic labels required by the Service Objects and the UI forms.
[x] Problem 7: Final CI/CD & Linting Verification
Task: Run bin/lint to ensure the structure adheres to the standards defined in discourse-pipeline_18.yml.

###

[x] Problem 1: Serialization Layer Implementation
Status: You are currently rendering json directly in the controller (render json: { ... }).
Task: Implement app/serializers/academic_profile_serializer.rb to explicitly whitelist attributes. This prevents accidental exposure of database internals (e.g., full Group model metadata) to the client-side.
[x] Problem 2: Input Contract Validation
Status: AcademicProfileController performs basic parameter extraction.
Task: Use params.require combined with custom validation logic to ensure the mappings payload matches the expected schema before passing it to the AssignAcademicGroups service object.
Phase 2: Quality Assurance & Automated Testing (Medium Priority)
[ ] Problem 3: E2E System Specs (spec/system/)
Task: Implement an RSpec system spec using the PageObjects pattern to simulate an admin setting the academic titles, clicking "Sync," and verifying the group changes in the backend. This is mandatory for your CI/CD pipeline.
[ ] Problem 4: JavaScript Unit Testing (test/javascripts/)
Task: Write a QUnit component test for admin-academic-profile-panel.gjs. Verify that FormKit correctly updates isSubmitting and handles AJAX errors when the sync fails.
Phase 3: Publication & Standard Compliance (Low Priority)
[ ] Problem 5: Comprehensive README.md
Task: Scaffold a README.md in the root directory following the standard template (Title, Description, Installation, Configuration, License, Screenshots).
[ ] Problem 6: CI/CD Workflow Finalization
Task: Audit .github/workflows/discourse-plugin.yml. Ensure the linting job is explicitly running bin/lint --plugin discourse-bekcan-academic-profile to enforce RuboCop and ESLint rules.