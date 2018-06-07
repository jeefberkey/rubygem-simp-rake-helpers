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

    def validate_json
      require 'json'
      Dir.glob("**/*.json").map do |json_file|
        print "Attempting to load #{json_file} ... "
        begin
          JSON.load(File.new(json_file))
          print 'ok'
        rescue JSON::ParserError => e
          print "failed: #{e}"
          exit 1
        end
        puts
      end
    end

    def validate_yaml
      require 'yaml'
      Dir.glob("**/*.y{,a}ml").map do |yaml_file|
        print "Attempting to load #{yaml_file} ... "

        begin
          YAML.load(File.new(yaml_file))
          print 'ok'
        rescue Psych::SyntaxError => e
          print "failed: #{e}"
          exit 1
        end
        puts
      end
    end

    def define
      namespace :util do
        desc 'Run puppet strings, and print all class params in their namespace'
        task :get_params do
          get_params
        end

        desc 'Validate all json files in working directory'
        task :validate_json do
          validate_json
        end

        desc 'Validate all yaml files in working directory'
        task :validate_yaml do
          validate_yaml
        end
      end
    end
  end
end
