require 'bundler'
Bundler.require

require 'dotenv'
Dotenv.load

require 'yaml'

Sequel.extension :migration

DB = Sequel.connect(ENV['DATABASE_URL'])
Sequel::Migrator.run(DB, ::File.join(::File.dirname(__FILE__), 'lib/migrations'))

require './lib/models/session'

namespace :db do
  task :seed do
    Dir["data/*"].each do |directory|
      next unless File.directory? directory
      year = Integer(directory.split(/\//).last)

      YAML.load(File.open(File.join(directory, "_sessions.yml"))).each do |number, attributes|
        previous = nil

        session = Session.find(year: year, number: number) || Session.new
        session.title = attributes[:title]
        session.description = attributes[:description]
        session.track = attributes[:track]
        session.number = number
        session.year = year

        filename = "data/#{year}/#{number}.vtt"
        if File.exist?(filename)
          session.transcript = File.read(filename).lines.delete_if{|line|
            line == "\n" ||
            line[0] == "[" ||
            /^WEBVTT/ === line ||
            /^X-TIMESTAMP-MAP/ === line ||
            /^\d+/ === line ||
            / --> / === line
          }.delete_if{|line|
            line == previous and previous = line
          }.collect{|line|
            line.gsub(/[\r\n]+/, " ").gsub(/(&gt\;|\-\-)/, "").gsub(/^>>/, "")
          }.join
        end

        puts session
        session.save
      end
    end
  end
end
