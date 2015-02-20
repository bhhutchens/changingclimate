def oauth_client
  TwitterOAuth::Client.new(:consumer_key => ENV['TWITTER_KEY'], :consumer_secret => ENV['TWITTER_SECRET'])
end

def client(access_token, secret_token)
  TwitterOAuth::Client.new(
    :consumer_key => ENV['TWITTER_KEY'],
    :consumer_secret => ENV['TWITTER_SECRET'],
    :token => access_token,
    :secret => secret_token)
end