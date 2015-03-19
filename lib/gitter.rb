require 'octokit'
require 'pry'

class Gitter
  def connect
    @client = Octokit::Client.new(access_token: "9048107b47ff2be264ead8a0328b32415e784813")
  end

  def authenticated?
    return !@client.nil?
  end

  def get_repos username
    @client.repositories username
  end

  def get_sorted_repos username
    get_repos(username).sort do |repo1, repo2|
      repo2.stars <=> repo1.stars
    end
  end

end
