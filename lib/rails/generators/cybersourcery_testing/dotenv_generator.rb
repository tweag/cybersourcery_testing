module CybersourceryTesting
  module Generators
    class DotenvGenerator < Rails::Generators::Base
      desc 'Creates a sample .env file for the Cybersourcery Testing gem'

      def self.source_root
        @source_root ||= File.expand_path('../templates', __FILE__)
      end

      def create_dotenv_file
        template 'dotenv', File.join('.env.cybersourcery_testing_sample')
      end
    end
  end
end
