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

  describe "Repo list" do
    let(:user) { "ishaansingal" }
    before do
      gitter.connect
    end

    use_vcr_cassette "user's repose"
    it "gets a list of all repos for a user" do
      user_repos = gitter.get_repos user
      expect(user_repos.count).to eql(8)
    end

    # it "sorts the repo list by stars" do
    #   user_repos = gitter.get_repos user
    # end
  end
end
