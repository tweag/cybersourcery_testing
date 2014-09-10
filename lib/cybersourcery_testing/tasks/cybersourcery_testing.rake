namespace :cybersourcery do
  require 'rubygems'
  require 'bundler/setup'
  require 'rakeup'

  desc 'Start the Cybersourcery translating proxy test server'
  task :translating_proxy do
    if ENV['CYBERSOURCERY_TRANSLATING_PROXY_RU_PATH'].present?
      ru_path = ENV['CYBERSOURCERY_TRANSLATING_PROXY_RU_PATH']
    else
      ru_path = "#{File.expand_path File.dirname(__FILE__)}/../translating_proxy.ru"
    end

    RakeUp::ServerTask.new('translating_proxy') do |t|
      t.run_command = "#{ENV['CYBERSOURCERY_TRANSLATING_PROXY_RUNNER']} -p #{ENV['CYBERSOURCERY_TRANSLATING_PROXY_PORT']} #{ru_path}"
    end

    Rake::Task['translating_proxy'].invoke
  end

  desc 'Start the Cybersourcery target host test server'
  task :target_host do
    if ENV['CYBERSOURCERY_TARGET_HOST_RB_PATH'].present?
      target_host_path = ENV['CYBERSOURCERY_TARGET_HOST_RB_PATH']
    else
      target_host_path = "#{File.expand_path File.dirname(__FILE__)}/../target_host.rb"
    end

    RakeUp::ServerTask.new('target_host') do |t|
      t.run_command = "#{ENV['CYBERSOURCERY_TARGET_HOST_RUNNER']} #{target_host_path} -p #{ENV['CYBERSOURCERY_TARGET_HOST_PORT']}"
    end

    Rake::Task['target_host'].invoke
  end
end
