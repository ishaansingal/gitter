require 'sinatra'
require './lib/gitter.rb'

get '/' do
  'User contribution list!'
end

get '/:username' do
  gitter = Gitter.new
  gitter.connect
  # all_repos = gitter.get_original_repos(params[:username]).map{|repo| repo.full_name }
  all_repos = gitter.get_repos(params[:username]).map{|repo| repo.full_name }
  gitter.contributions_hash all_repos, params[:username]
end
