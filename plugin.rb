# frozen_string_literal: true

# name: discourse-robin-sso
# about: Hwork 主系统 SSO 集成插件
# version: 1.0.0
# authors: Robin
# url: https://github.com/discourse/discourse-robin-sso

enabled_site_setting :hwork_sso_enabled

after_initialize do
  require_relative "lib/hwork_token_authenticator"
  require_relative "app/controllers/hwork_sso_controller"

  # 添加路由
  Discourse::Application.routes.append do
    get "/hwork-sso" => "hwork_sso#login"
  end

  # 扩展 CurrentUser 以支持 Token 认证
  module ::Auth::DefaultCurrentUserProvider::HworkTokenAuth
    def current_user
      if SiteSetting.hwork_sso_enabled
        token = @env["HTTP_X_SYSTEM_TOKEN"]
        if token.present?
          user = HworkTokenAuthenticator.authenticate(token)
          return user if user
        end
      end
      super
    end
  end

  class ::Auth::DefaultCurrentUserProvider
    prepend ::Auth::DefaultCurrentUserProvider::HworkTokenAuth
  end
end
