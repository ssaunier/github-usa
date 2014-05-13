# Usage: ruby -Ilib map.rb

require 'geo'

require 'csv'
require 'json'
require 'colorize'

max_ratio = nil
min_ratio = 0.01

features = []

csv = CSV.parse(File.read('data/github_users_per_state.csv'), :headers => true)
csv.each do |row|
  row_hash = row.to_hash
  abbr = row_hash["Abbr"]
  puts "Fetching #{abbr}"
  ratio = row["Dev per 1000 inhab."].to_f
  max_ratio = ratio if max_ratio.nil?

  opacity = Math.log(ratio * (Math::E - 1) / max_ratio + 1)
  begin
    features << Geo.new.geo_json(abbr, row_hash, opacity)
  rescue OpenURI::HTTPError => e
    puts "Could not fetch geojson for #{row_hash["Abbr"]} - #{e.message}".colorize(:yellow)
    retry unless e.message =~ /404/
  end
end

feature_collection = {
  "type" => "FeatureCollection",
  "features" => features
}

File.open('data/github_users_per_state.geojson', 'w') do |f|
  f.write JSON.pretty_generate(feature_collection)
end