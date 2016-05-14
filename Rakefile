require 'bundler'
Bundler.require

require 'yaml'

Sequel.extension :core_extensions, :migration
DB = Sequel.connect(ENV['DATABASE_URL'])
DB.extension :pg_array
Sequel::Migrator.run(DB, ::File.join(::File.dirname(__FILE__), 'lib/migrations'))

require './lib/models/session'

namespace :db do
  task :seed, [:year] do |task, args|
    yearMatch = args.year || "none"
    
    Dir["data/*"].each do |directory|
      next unless File.directory? directory
      next if directory == 'tools'
      
      year = Integer(directory.split(/\//).last)
      next unless yearMatch == "#{year}" || yearMatch == "none"
      puts "\n#{year}\n----"

      YAML.load(File.open(File.join(directory, "_sessions.yml"))).each do |number, attributes|
        session = Session.find(year: year, number: number) || Session.new
        session.title = attributes[:title]
        session.description = attributes[:description]
        session.track = attributes[:track]
        session.number = number
        session.year = year

        filename = "data/#{year}/#{number}.vtt"
        if File.exist?(filename)
          annotations, timecodes, previous = [], [], nil

          File.read(filename).gsub(/\r\n?/, "\n").split(/\n\n/).each do |chunk|
            lines = []
            timecode = nil

            chunk.split(/\n/).each do |line|
              case line
              when /^WEBVTT/, /^X-TIMESTAMP-MAP/
                next
              when /^\d+$/
                next
              when / --> /
                h, m, s, d = line.match(/(\d{2})\:(\d{2}):(\d{2})[\.\,]?(\d{3})?/).captures
                timecode = (h.to_i * 3600) + (m.to_i * 60) + (s.to_i) + ((d || 0.0).to_f / 1000) if h and m and s
              else
                lines << line.gsub(/[\r\n]+/, " ").gsub(/(&gt\;|\-\-)/, "").gsub(/^>>/, "").strip
              end
            end

            annotation = lines.join(" ")
            next if annotation.nil? or annotation.empty?
            next if annotation == previous
            previous = annotation

            annotations << annotation
            timecodes << timecode
          end
          
          session.annotations = annotations
          session.timecodes = timecodes
        end

        puts session
        session.save
      end
    end
  end
end
