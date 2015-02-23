get '/' do
  @top_users = User.all.order(tweet_count: :desc).limit(10)
  erb :index
end

get '/search' do
  erb :search
end

get '/results' do

  # finds representative info based on zipcode
  sunlight_url = 'https://congress.api.sunlightfoundation.com/legislators/locate?zip=' + params[:zipcode].to_s + '&apikey=' + ENV['SUNLIGHT_KEY']
  sunlight_response = HTTParty.get(sunlight_url)
  @reps = {}
  sunlight_response['results'].each do |rep|
    name = rep['first_name'] + ' ' + rep['last_name']
    email = rep['oc_email']
    bioguide_id = rep['bioguide_id']
    twitter_id = rep['twitter_id']
    @reps[name] = {email: email, bioguide_id: bioguide_id, twitter_id: twitter_id}
  end

  # for each rep, pull up their most recent congressional entries on the search term
  search_term_final = params[:search_term].gsub(/\s/, '%20')
  @reps.each do |name, hash|
    capitolwords_url = 'http://capitolwords.org/api/1/text.json?phrase=' + search_term_final + '&bioguide_id=' + @reps[name][:bioguide_id] + '&sort=date%20desc&page=0&apikey=' + ENV['SUNLIGHT_KEY']
    capitolwords_response = HTTParty.get(capitolwords_url)
    rep_records = []
    max = 3
    i = 0
    begin
      if capitolwords_response['results'][i]
        congressional_record = capitolwords_response['results'][i]['speaking']
        reference_url = capitolwords_response['results'][i]['capitolwords_url']
        date = capitolwords_response['results'][i]['date']
        rep_records.push({congressional_record: congressional_record, reference_url: reference_url, date: date})
      end
      i += 1
    end while i < max
    @reps[name][:rep_records] = rep_records
  end
  @search_term = params[:search_term].gsub(/\w+/, &:capitalize)

  erb :results

end

get '/oauth' do
  request_token = oauth_client.request_token(:oauth_callback => 'http://localhost:9393/oauth/callback')
  session[:request_token] = request_token.token
  session[:request_token_secret] = request_token.secret
  redirect request_token.authorize_url
end

get '/oauth/callback' do
  access_token = oauth_client.authorize(session[:request_token], session[:request_token_secret], :oauth_verifier => params[:oauth_verifier])
  session[:access_token] = access_token.token
  session[:secret_token] = access_token.secret
  @client = client(session[:access_token], session[:secret_token])
  info = @client.verify_credentials
  User.create(screen_name: info['screen_name'], profile_image_url_https: info['profile_image_url_https'], tweet_count: 0)
  session[:user_screen_name] = User.find_by(screen_name: info['screen_name']).screen_name
  redirect '/search'
end

post '/tweet' do
  user = User.find_by(screen_name: session[:user_screen_name])
  user.tweet_count += 1
  user.save
  @client = client(session[:access_token], session[:secret_token])
  @client.update(params[:tweet])
  redirect '/search'
end

post '/ajax/tweet' do
  content_type :json
  user = User.find_by(screen_name: session[:user_screen_name])
  user.tweet_count += 1
  user.save
  @client = client(session[:access_token], session[:secret_token])
  @client.update(params[:tweet])
  {tweet: params[:tweet]}.to_json
end