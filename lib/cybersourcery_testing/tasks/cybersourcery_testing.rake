require 'sinatra'

namespace :cybersourcery_testing do
  task :run do
    #require 'app'
    Sinatra::Application.run!
  end
end
