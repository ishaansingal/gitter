require 'sinatra'
require 'faraday-http-cache'
require './lib/gitter.rb'

stack = Faraday::RackBuilder.new do |builder|
  builder.use Faraday::HttpCache
  builder.use Octokit::Response::RaiseError
  builder.request :url_encoded
  builder.adapter Faraday.default_adapter
  # builder.response :logger
end
Octokit.middleware = stack

get '/' do
  'User contribution list!'
end

get '/:username/*' do
  gitter = Gitter.new
  gitter.connect
  # all_repos = gitter.get_original_repos(params[:username]).map{|repo| repo.full_name }
  # all_repos = gitter.get_repos("ishaansingal").map{|repo| repo.full_name }
  # hash = gitter.contributions_hash ["spree/spree"], "JDutil"
  repo = params[:splat].first
  hash = gitter.contributions_hash [repo], params[:username]
  erb :index, :locals => {:repo_contributions => hash}
end

get '/:username' do
  gitter = Gitter.new
  gitter.connect
  # all_repos = gitter.get_original_repos(params[:username]).map{|repo| repo.full_name }
  # all_repos = gitter.get_repos("ishaansingal").map{|repo| repo.full_name }
  # hash = gitter.contributions_hash ["spree/spree"], "JDutil"
  hash = gitter.contributions_hash ["ishaansingal/spree-adyen"], params[:username]
  erb :index, :locals => {:repo_contributions => hash}
  # erb "This is the final hash #{hash.to_s}"
end
