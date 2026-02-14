# frozen_string_literal: true

class HworkTokenAuthenticator
  HWORK_API_URL = "https://pre-hwork.haier.net/gw/login/api/v2/get-user-info"
  CACHE_DURATION = 5.minutes
  REQUEST_TIMEOUT = 5

  def self.authenticate(token)
    return nil if token.blank?

    user_info = verify_token(token)
    return nil unless user_info

    find_or_create_user(user_info)
  rescue => e
    Rails.logger.error("Hwork SSO Error: #{e.message}")
    nil
  end

  private

  def self.verify_token(token)
    cache_key = "hwork_token:#{Digest::SHA256.hexdigest(token)}"
    
    Rails.cache.fetch(cache_key, expires_in: CACHE_DURATION) do
      fetch_user_info(token)
    end
  end

  def self.fetch_user_info(token)
    response = Faraday.new do |f|
      f.options.timeout = REQUEST_TIMEOUT
      f.options.open_timeout = REQUEST_TIMEOUT
    end.get(HWORK_API_URL) do |req|
      req.headers["Authorization"] = "Bearer #{token}"
    end

    return nil unless response.success?

    data = JSON.parse(response.body)
    return nil unless data["code"] == 200

    {
      user_id: data["userId"],
      user_name: data["userName"],
      email: data["email"]
    }
  rescue => e
    Rails.logger.error("Hwork API Error: #{e.message}")
    nil
  end

  def self.find_or_create_user(user_info)
    username = "user_#{user_info[:user_id]}"
    email = user_info[:email] || "#{username}@hwork.local"

    user = User.find_by(username: username)
    return user if user

    User.create!(
      username: username,
      name: user_info[:user_name],
      email: email,
      password: SecureRandom.hex(32),
      active: true,
      approved: true,
      trust_level: TrustLevel[1]
    )
  rescue => e
    Rails.logger.error("User creation error: #{e.message}")
    nil
  end
end
