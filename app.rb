##
# Main web app definition
class GeckoWeather < Sinatra::Base
  YAHOO_URL = 'https://query.yahooapis.com/v1/public/yql'.freeze
  QUERY_TEMPLATE = 'select item.condition from weather.forecast where woeid = %{id} and u="%{unit}"'.freeze
  MARKUP_TEMPLATE = "<div class='t-size-x72'>%{temp}&deg;</div><div>%{text}</div>".freeze
  ERROR_MESSAGE = "<div class='t-size-x72'>Error fetching weather</div>".freeze

  set :public_folder, Proc.new { File.join(root, "public") }

  get '/' do
    redirect '/index.html'
  end

  get '/weather/:id' do
    query = QUERY_TEMPLATE % { id: params['id'], unit: params['unit'] }
    weather_response = HTTP.get YAHOO_URL,
                                params: { q: query, format: :json, u: 'c' }

    if weather_response.code == 200
      condition = JSON.parse(weather_response.to_s).dig('query',
                                                        'results',
                                                        'channel',
                                                        'item',
                                                        'condition')
      json(
        item: {
          text: MARKUP_TEMPLATE % { temp: condition['temp'],
                                    text: condition['text'] }
        }
      )
    else
      json(
        item: {
          text: ERROR_MESSAGE
        }
      )
    end
  end
end
