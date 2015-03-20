require 'octokit'
require 'pry'

class Gitter
  def connect
    @client = Octokit::Client.new(access_token: ENV["github_auth"])
  end

  def authenticated?
    return !@client.nil?
  end

  def get_repos username
    @client.repositories(username).map do |repo|
      @client.repo repo.full_name
    end
  end

  def get_original_repos username
    @client.repositories(username).map do |repo|
      if repo.fork
        @client.repo(repo.full_name).parent
      else
        repo
      end
    end
  end

  def get_sorted_repos username
    get_repos(username).sort do |repo1, repo2|
      repo1 = repo1.parent if repo1.parent
      repo2 = repo2.parent if repo2.parent
      repo2.stargazers_count <=> repo1.stargazers_count
    end
  end

  def contribution repo, username 
    commits = @client.commits(repo, { author: username })
    next_url = @client.last_response.rels[:next]
    while ! next_url.nil? do
      commits.concat Octokit.get(next_url.href)
      next_url = Octokit.last_response.rels[:next]
    end
    commits.map do |commit|
      @client.commit repo, commit.sha
    end
  end

  def files_changed_in_commit commit
    commit.files.map do |file_change|
      {
        filename: file_change.filename,
        changes: file_change.changes
      }
    end
  end

  def group_contributions_for_repo commits
    file_hash = {}
    file_hash.default = 0
    commits.each do |commit|
      files_changed_in_commit(commit).each do |change|
        file_hash[change[:filename].split('.')[1]] += change[:changes]
      end
    end
    file_hash
  end

  def contributions_hash repos, username
    final_hash = {}
    final_hash.default = 0
    repos.each do |repo|
      final_hash[repo] = group_contributions_for_repo contribution(repo, username)
    end
    final_hash
  end
end
