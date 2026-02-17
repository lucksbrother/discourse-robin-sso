# frozen_string_literal: true

class HworkSsoController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:login]
  skip_before_action :check_xhr, only: [:login]
  skip_before_action :redirect_to_login_if_required, only: [:login]

  def login
    token = params[:token]
    
    if token.blank?
      render json: { error: "Token is required" }, status: :bad_request
      return
    end

    # 验证 token 并获取用户
    user = HworkTokenAuthenticator.authenticate(token)
    
    if user.nil?
      render json: { error: "Invalid token or authentication failed" }, status: :unauthorized
      return
    end

    # 创建登录会话
    log_on_user(user)
    
    # 将 token 存储到 cookie 中，前端 JS 会读取并存入 localStorage
    cookies[:hwork_system_token] = {
      value: token,
      expires: 2.hours.from_now,
      httponly: false
    }

    # 直接重定向到首页
    redirect_to "/"
  end
end
