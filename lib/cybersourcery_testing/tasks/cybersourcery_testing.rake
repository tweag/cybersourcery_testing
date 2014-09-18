namespace :cybersourcery do
  require 'rubygems'
  require 'bundler/setup'
  require 'rakeup'

  desc 'Start the Cybersource SOP proxy server'
  task :proxy do
    if ENV['CYBERSOURCERY_SOP_PROXY_RB_PATH'].present?
      proxy_path = ENV['CYBERSOURCERY_SOP_PROXY_RB_PATH']
    else
      proxy_path = "#{File.expand_path File.dirname(__FILE__)}/../cybersource_proxy.rb"
    end

    RakeUp::ServerTask.new('cybersource_proxy') do |t|
      proxy_uri = URI ENV['CYBERSOURCERY_SOP_PROXY_URL']
      t.run_command = "#{ENV['CYBERSOURCERY_SOP_PROXY_RUNNER']} #{proxy_path} -p #{proxy_uri.port}"
    end

    Rake::Task['cybersource_proxy'].invoke
  end
end
