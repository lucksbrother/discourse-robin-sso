# frozen_string_literal: true

class HworkSsoController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:login]
  skip_before_action :check_xhr, only: [:login]

  def login
    token = params[:token]
    
    if token.blank?
      render json: { error: "Token is required" }, status: :bad_request
      return
    end

    render html: <<~HTML.html_safe
      <!DOCTYPE html>
      <html>
      <head>
        <title>Hwork SSO Login</title>
      </head>
      <body>
        <script>
          localStorage.setItem("hwork_system_token", "#{token}");
          window.location.href = "/";
        </script>
      </body>
      </html>
    HTML
  end
end
