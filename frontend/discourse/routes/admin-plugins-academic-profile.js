/** @ts-check */
import Route from "@ember/routing/route";
import { ajax } from "discourse/lib/ajax";

export default class AdminPluginsAcademicProfileRoute extends Route {
  model() {
    return ajax("/admin/plugins/academic-profile");
  }
}