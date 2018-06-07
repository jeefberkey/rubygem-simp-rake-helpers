require 'rake/tasklib'

module Simp; end
module Simp::Rake
  class Simp::Rake::Util < ::Rake::TaskLib
    def initialize
      define
    end

    def get_params
      require 'json'
      strings = JSON.load(`bundle exec puppet strings generate --format json`)

      params = []
      strings['puppet_classes'].each do |pup_class|
        param_list = pup_class['defaults'] ? pup_class['defaults'].keys : []

        params << param_list.map do |param|
          pup_class['name'] + '::' + param
        end
      end

      puts params.flatten.compact.join("\n")
    end

    def define
      namespace :util do
        desc 'Run puppet strings, and print all class params in their namespace'
        task :get_params do
          get_params
        end
      end
    end
  end
end
