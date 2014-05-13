# Usage: ruby -Ilib github_users_per_state.rb

require 'states'
require 'github'

require 'yaml'
require 'octokit'
require 'thread/pool'

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

File.open('data/github_users_per_state.yml', 'w') do |f|
  f.write STATES.sort_by{ |s| s[:ratio] }.reverse.to_yaml
end
