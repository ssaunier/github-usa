# Usage: ruby -Ilib github_users_per_state.rb

require 'states'
require 'github'

require 'yaml'
require 'octokit'
require 'thread/pool'
require 'csv'
require 'colorize'

TOKENS = File.readlines(".tokens").map &:chomp

def client
  Octokit::Client.new :access_token => TOKENS.sample
end

states_github_user_count = Hash.new

pool = Thread.pool(8)
STATES.each_with_index do |state, i|
  pool.process do
    STATES[i][:github] = Github.new(client).count_github_users(state[:abbr], state[:name])
    STATES[i][:ratio] = (STATES[i][:github].fdiv(STATES[i][:population]) * 1000).round(2)
  end
end
pool.shutdown


def color(state)
  state[:ratio] >= 0.5 ? :green : (state[:ratio] >= 0.1 ? :yellow : :red)
end

CSV.open("data/github_users_per_state.csv", "wb", write_headers: true, headers: ["Abbr", "State", "GitHub", "Population", "Dev per 1000 inhab."]) do |csv|
  STATES.sort_by{ |s| s[:ratio] }.reverse.each_with_index do |state, index|
    color = color(state)
    index = (index + 1).to_s.rjust(3)
    puts "#{index} [" + state[:name].colorize(color) + "] " + state[:ratio].to_s.colorize(color) +
        " with #{state[:github]} GitHub users over #{state[:population]} inhabitants"

    csv << [state[:abbr], state[:name], state[:github], state[:population], state[:ratio]]
  end
end

puts "DE must be adjusted by hand as search brings 'Rio De Janeiro'"
puts "PR must be adjusted by hand as search brings 'Curitiba, PR, Brazi'"
