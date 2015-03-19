require 'sinatra'
require './lib/gitter.rb'

get '/' do
  'User contribution list!'
end

get '/:username' do
  gitter = Gitter.new
  gitter.connect
  all_repos = gitter.get_original_repos("ishaansingal").map{|repo| repo.full_name }
  # all_repos = gitter.get_repos("ishaansingal").map{|repo| repo.full_name }
  hash = gitter.contributions_hash all_repos, "ishaansingal"
  erb "This is the final hash #{hash.to_s}"
end
