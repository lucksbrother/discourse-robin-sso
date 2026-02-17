import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.8.0", (api) => {
  // 从 cookie 读取 token 并存入 localStorage
  const cookieToken = document.cookie
    .split('; ')
    .find(row => row.startsWith('hwork_system_token='));
  
  if (cookieToken) {
    const token = cookieToken.split('=')[1];
    if (token && token !== localStorage.getItem("hwork_system_token")) {
      localStorage.setItem("hwork_system_token", token);
    }
  }

  // 拦截所有 AJAX 请求，自动添加 token header
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
