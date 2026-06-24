export default function () {
  this.route("adminPlugins", { path: "/admin/plugins" }, function () {
    // plugin.rb'deki add_admin_route ikinci parametresi ile eşleşmeli
    this.route("academic-profile"); 
  });
}