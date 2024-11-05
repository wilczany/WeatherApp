
#rubocop:disable all
require 'sinatra'
require 'json'


# {
#   "sensors": {
#     "1": {
#       "name": "czujnik1",
#       "type": "indoor",
#       "temp": " ",
#       "humid": " ",
#       "pressure": " "
#     },
#     "2": {
#       "name": "czujnik2",
#       "type": "outside",
#       "temp": " ",
#       "humid": " ",
#       "pressure": " "
#     }
#   }
# }

get '/' do
  content_type :json
  { 
    sensors: {
      1 => {
        name: 'czujnik1',
        type: 'indoor',
        temp: rand(10.0..12.0).round(2),
        humid: rand(30..60).round(2),
        pressure: rand(990..1010)
      },
      2 => {
        name: 'czujnik2',
        type: 'outside',
        temp: rand(10.0..12.0).round(2),
        humid: rand(30..60).round(2),
        pressure: rand(990..1010)
      }
    }
  }.to_json
end
