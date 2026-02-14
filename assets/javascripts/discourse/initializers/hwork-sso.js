import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.8.0", (api) => {
  api.modifyClass("lib:ajax", {
    pluginId: "discourse-hwork-sso",
    
    ajax(url, settings = {}) {
      const token = localStorage.getItem("hwork_system_token");
      if (token) {
        settings.headers = settings.headers || {};
        settings.headers["X-System-Token"] = token;
      }
      return this._super(url, settings);
    }
  });
});
