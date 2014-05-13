# Usage: ruby -Ilib map.rb

require 'geo'

require 'csv'
require 'json'
require 'colorize'

$max_ratio = nil

def color(ratio)
  ratio >= 0.5 ? "#27ae60" : (ratio >= 0.1 ? "#e67e22" : "#c0392b")
end

def opacity(ratio)
  max_ratio = ratio >= 0.5 ? $max_ratio : (ratio >= 0.1 ? 0.5 : 0.1)
  Math.log(1 + ratio * (Math::E - 1) / max_ratio)
end

features = []

csv = CSV.parse(File.read('data/github_users_per_state.csv'), :headers => true)
csv.each do |row|
  row_hash = row.to_hash
  abbr = row_hash["Abbr"]
  ratio = row["Dev per 1000 inhab."].to_f
  $max_ratio = ratio if $max_ratio.nil?

  begin
    puts "Fetching #{abbr}"
    features << Geo.new.geo_json(abbr, row_hash, opacity(ratio), color(ratio))
  rescue OpenURI::HTTPError => e
    puts "Could not fetch geojson for #{abbr} - #{e.message}".colorize(:yellow)
    retry unless e.message =~ /404/
  end
end

File.open('data/github_users_per_state.geojson', 'w') do |f|
  f.write JSON.pretty_generate({
    "type" => "FeatureCollection",
    "features" => features
  })
end
