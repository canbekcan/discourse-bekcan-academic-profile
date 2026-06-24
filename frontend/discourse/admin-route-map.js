/** @ts-check */
export default function () {
  this.route("adminPlugins", { path: "/admin/plugins" }, function() { this.route("academic-profile"); });
}