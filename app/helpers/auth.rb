helpers do
  def auth_client
    @auth_client = OAuth2::Client.new(ENV['TWITTER_KEY'], ENV['TWITTER_SECRET'], { :site => 'https://api.twitter.com', :token_url => '/oauth/request_token', :authorize_url => '/oauth/authorize' })
  end

  def auth_authorize_link
    auth_client.auth_code.authorize_url(:redirect_uri => 'https://localhost:9393/oauth/callback')
  end

  def auth_process_code(code)
    new_token = auth_client.auth_code.get_token(code, :redirect_uri => 'https://localhost:9393/oauth/callback')
    auth_set_current_user(new_token.token)
  end

  def auth_set_current_user(token, refresh_token)
    session[:access_token] = token
    # session[:refresh_token] = refresh_token
    # session[:user_info] = auth_token_wrapper.get("https://www.googleapis.com/oauth2/v3/userinfo").parsed
  end

  def auth_sign_out
    session.delete :access_token
    session.delete :refresh_token
    session.delete :user_info
  end

end