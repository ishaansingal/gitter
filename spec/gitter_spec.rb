require 'gitter'
require 'octokit'
require 'vcr_setup'

RSpec.configure do |c|
    c.extend VCR::RSpec::Macros
end

describe Gitter do

  # before do
  #   allow(Octokit::Client).to receive(:new).and_return("")
  #   allow(Octokit::Client).to receive(:repositories)
  # end
  let(:gitter) { Gitter.new }

  describe "auth" do
    it "connects to github api" do
      gitter = Gitter.new
      expect(Octokit::Client).to receive(:new).exactly(1).times
      gitter.connect
    end
  end

  use_vcr_cassette "user's repose"
  describe "Repo list" do
    let(:user) { "ishaansingal" }
    before do
      gitter.connect
    end

    it "gets a list of all repos for a user" do
      user_repos = gitter.get_repos user
      expect(user_repos.count).to eql(8)
    end

    it "should contain the parent repos for forked copies" do
      user_repos = gitter.get_repos user
      spree_repos = user_repos.select{|repo| repo.name == "spree"}
      expect(spree_repos.count).to eql(1)
      expect(spree_repos.first.parent.full_name).to eql("spree/spree")
    end

    it "sorts the repo list by stars" do
      user_repos = gitter.get_sorted_repos user
      expect(user_repos[0..2].map(&:name)).to eql(["spree","adyen","spree-adyen"])
    end
  end

  use_vcr_cassette "author_commits"
  describe "Contributions" do
    let(:user) { "ishaansingal" }

    before do
      gitter.connect
    end

    it "receives all the commits for a repo" do
      commits = gitter.contribution "ishaansingal/spree-adyen", "ishaansingal"
      expect(commits.count).to eql(1)
    end

    it "receives the files changed for a repo" do
      commits = gitter.contribution "ishaansingal/spree-adyen", "ishaansingal"
      files_changed = gitter.files_changed_in_commit commits.first
      expect(files_changed.count).to eql(1)
      expect(files_changed.first.keys.count).to eql(2)
      expect(files_changed.first[:filename]).to eql("spree-adyen.gemspec")
    end

    it "groups contributions based on file-type for a repo" do
      commits1 = gitter.contribution "ishaansingal/spree-adyen", "ishaansingal"
      files_hash1 = gitter.group_contributions_for_repo commits1

      commits2= gitter.contribution "ishaansingal/adyen", "ishaansingal"
      files_hash2= gitter.group_contributions_for_repo commits2

      expect(files_hash1["gemspec"]).to eql(2)
      expect(files_hash2["rb"]).to eql(81)
    end

    it "groups different repos in key based hash" do
      all_repo_hash = gitter.contributions_hash ["ishaansingal/adyen", "ishaansingal/spree-adyen"], "ishaansingal"

      expect(all_repo_hash.keys.count).to eql(2)
      expect(all_repo_hash["ishaansingal/adyen"]["rb"]).to eq(81)
      expect(all_repo_hash["ishaansingal/spree-adyen"]["gemspec"]).to eq(2)
    end
  end
end
