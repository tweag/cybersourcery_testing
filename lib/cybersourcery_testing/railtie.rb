require 'cybersourcery_testing'
require 'rails'

module CybersourceryTesting
  class Railtie < Rails::Railtie
    railtie_name :cybersourcery_testing

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__),'/tasks/*.rake')].each { |f| load f }
    end
  end
end
