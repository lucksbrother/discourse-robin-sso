# frozen_string_literal: true

class HworkSsoController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:login, :auto_login, :cookie_login_page]
  skip_before_action :check_xhr, only: [:login, :auto_login, :cookie_login_page]
  skip_before_action :redirect_to_login_if_required, only: [:login, :auto_login, :cookie_login_page]

  # 原有的 URL 跳转登录（保留兼容）
  def login
    token = params[:token]

    if token.blank?
      render json: { error: "Token is required" }, status: :bad_request
      return
    end

    perform_login(token)
  end

  # Cookie 登录页面（直接执行登录）
  def cookie_login_page
    token = get_token_from_cookie

    if token.blank?
      render html: error_html("未找到登录凭证").html_safe, layout: false
      return
    end

    user = HworkTokenAuthenticator.authenticate(token)

    if user.nil?
      render html: error_html("登录凭证无效").html_safe, layout: false
      return
    end

    log_on_user(user)
    redirect_to "/"
  end

  # 基于 Cookie 的自动登录 API
  def auto_login
    token = get_token_from_cookie

    if token.blank?
      render json: { success: false, message: "No token found" }, status: :ok
      return
    end

    perform_login(token, json_response: true)
  end

  private

  def get_token_from_cookie
    env = SiteSetting.hwork_environment || "staging"
    cookie_names = {
      "test" => "hwork_token_test",
      "staging" => "hwork_token_pre",
      "production" => "hwork_token_prod"
    }
    cookies[cookie_names[env]]
  end

  def perform_login(token, json_response: false)
    user = HworkTokenAuthenticator.authenticate(token)

    if user.nil?
      if json_response
        render json: { success: false, message: "Invalid token" }, status: :ok
      else
        render json: { error: "Invalid token or authentication failed" }, status: :unauthorized
      end
      return
    end

    log_on_user(user)

    if json_response
      render json: { success: true, username: user.username }
    else
      redirect_to "/"
    end
  end

  def cookie_login_html
    env = SiteSetting.hwork_environment || "staging"
    cookie_names = {
      "test" => "hwork_token_test",
      "staging" => "hwork_token_pre",
      "production" => "hwork_token_prod"
    }
    cookie_name = cookie_names[env]

    <<-HTML
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>正在登录...</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
      background: #f5f5f5;
    }
    .container {
      text-align: center;
      padding: 40px;
      background: white;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    .spinner {
      border: 3px solid #f3f3f3;
      border-top: 3px solid #3498db;
      border-radius: 50%;
      width: 40px;
      height: 40px;
      animation: spin 1s linear infinite;
      margin: 0 auto 20px;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    .message { color: #666; margin-top: 10px; }
    .error { color: #e74c3c; }
  </style>
</head>
<body data-cookie-name="#{cookie_name}">
  <div class="container">
    <div class="spinner"></div>
    <div id="message" class="message">正在验证登录信息...</div>
  </div>
</body>
</html>
    HTML
  end

  def error_html(message)
    <<-HTML
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="refresh" content="3;url=/">
  <title>登录失败</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
      background: #f5f5f5;
    }
    .container {
      text-align: center;
      padding: 40px;
      background: white;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    .error { color: #e74c3c; font-size: 18px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="error">#{message}</div>
    <p>3秒后跳转到首页...</p>
  </div>
</body>
</html>
    HTML
  end
end
