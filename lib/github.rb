class Github
  def initialize(client)
    @client = client
  end

  def count_github_users(state_abbr, state_name)
    count(state_abbr) + count(state_name)
  rescue Octokit::TooManyRequests
    sleep 1
    puts "Rate limit reached (20rpm), sleeping for 1 second...".colorize(:gray)
    retry
  end

  private

    def count(search)
      query = @client.search_users("location:\"#{search}\"")
      query[:total_count]
    end
end