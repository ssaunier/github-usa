# Usage: ruby -Ilib map.rb

require 'geo'
require 'csv'
require 'json'

max_ratio = nil

features = []

csv = CSV.parse(File.read('data/github_users_per_state.csv'), :headers => true)
csv.each do |row|
  row_hash = row.to_hash
  ratio = row["Dev per 1000 inhab."].to_f
  max_ratio = ratio if max_ratio.nil?
  begin
    features << Geo.new.geo_json(row["Abbr"], row_hash, ratio / max_ratio)
  rescue OpenURI::HTTPError => e
    puts "Could not fetch geojson for #{row_hash["Abbr"]} - #{e.message}"
  end
end

feature_collection = {
  "type" => "FeatureCollection",
  "features" => features
}

File.open('data/github_users_per_state.geojson', 'w') do |f|
  f.write JSON.pretty_generate(feature_collection)
end