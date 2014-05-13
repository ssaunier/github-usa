require 'open-uri'
require 'json'

class Geo
  ROOT = "https://raw.githubusercontent.com/johan/world.geo.json/master/countries/USA/"

  def geo_json(abbr, properties, opacity, color)
    json = JSON.load(open(source(abbr)))
    feature = json["features"].first
    feature["properties"] = properties
    feature["properties"]["fill"] = color
    feature["properties"]["fill-opacity"] = opacity
    feature
  end

  private

    def source(state_abbr)
      "#{ROOT}#{state_abbr}.geo.json"
    end
end