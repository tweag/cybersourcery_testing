namespace :cybersourcery do
  require 'rubygems'
  require 'bundler/setup'
  require 'rakeup'

  desc 'Start the Cybersourcery translating proxy test server'
  task :translating_proxy, [:config_path, :ru_path] => [:environment] do |t, args|
    config_path = args.config_path.present? ? args.config_path : "#{Rails.root}/config/cybersourcery_testing.yml"
    config = YAML.load_file config_path

    default_ru_path = "#{File.expand_path File.dirname(__FILE__)}/../translating_proxy.ru"
    ru_path = args.ru_path.present? ? args.ru_path : default_ru_path

    RakeUp::ServerTask.new('translating_proxy') do |t|
      t.run_command = "#{config['translating_proxy_runner']} -p #{config['translating_proxy_port']} #{ru_path}"
    end

    Rake::Task['translating_proxy'].invoke
  end

  desc 'Start the Cybersourcery target host test server'
  task :target_host, [:config_path, :target_host_path] => [:environment] do |t, args|
    config_path = args.config_path.present? ? args.config_path : "#{Rails.root}/config/cybersourcery_testing.yml"
    config = YAML.load_file config_path

    default_target_host_path = "#{File.expand_path File.dirname(__FILE__)}/../target_host.rb"
    target_host_path = args.target_host_path.present? ? args.target_host_path : default_target_host_path

    RakeUp::ServerTask.new('target_host') do |t|
      t.run_command = "#{config['target_host_runner']} #{target_host_path} -p #{config['target_host_port']}"
    end

    Rake::Task['target_host'].invoke
  end
end
