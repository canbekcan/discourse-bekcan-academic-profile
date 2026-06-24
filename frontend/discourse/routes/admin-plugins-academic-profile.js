/** @ts-check */
import Route from "@ember/routing/route";
import { ajax } from "discourse/lib/ajax";

export default class AdminPluginsAcademicProfile extends Route {
  async model() {
    // Fetches initial configuration for the admin panel
    return await ajax("/admin/plugins/academic-profile/data");
  }

  setupController(controller, model) {
    super.setupController(controller, model);
    controller.set("model", model);
  }
}