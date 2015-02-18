get '/' do
  erb :index
end

get '/zipcode' do

 climate_response = HTTParty.get('http://climatedataapi.worldbank.org/climateweb/rest/v1/country/annualanom/tas/2020/2039/USA')

 counter = 0
 total = 0
 climate_response.each do |model_data|
  total = total + model_data['annualData'][0]
  counter = counter + 1
 end

 @average_annual_change = total / counter

 sunlight_url = 'https://congress.api.sunlightfoundation.com/legislators/locate?zip=' + params[:zipcode].to_s + '&apikey=db117ccbb61e4b82abc74d37a9b58ed2'
 sunlight_response = HTTParty.get(sunlight_url)
 @reps = {}
 sunlight_response['results'].each do |rep|
  name = rep['first_name'] + ' ' + rep['last_name']
  email = rep['oc_email']
  @reps[name] = email
 end

 puts @reps
 puts @average_annual_change

 erb :zipcode

end


