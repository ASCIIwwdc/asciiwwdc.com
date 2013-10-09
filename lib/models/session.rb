require 'ostruct'

class Session < Sequel::Model
  plugin :json_serializer, naked: true, except: [:id, :tsv]
  plugin :validation_helpers
  plugin :schema

  def self.search(query)
    query = Session.db.literal(query.to_s)

    Session.db[%{
      SELECT title, description, year, number,
             ts_rank_cd(
              (
                setweight(to_tsvector(title), 'A') ||
                setweight(to_tsvector(description), 'C') ||
                setweight(tsv, 'D')
              ),
              plainto_tsquery('english', #{query})
             ) AS rank,
             ts_headline(
              'pg_catalog.english', transcript, plainto_tsquery('english', #{query}),
              'ShortWord=0, MinWords=50, MaxWords=70'
             ) AS excerpt
             FROM sessions
             WHERE tsv @@ plainto_tsquery('english', #{query})
             ORDER BY rank DESC
    }].collect{|result| OpenStruct.new(result)}
  end

  def to_s
    "#{self.number} #{self.title}"
  end

  def validate
    super

    validates_presence [:title, :description, :year, :track, :transcript]
    validates_unique [:title, :year]
    validates_unique [:number, :year]
  end

  def before_save
    super

    html = ""

    self.transcript.split(/\.\s+/).each do |sentence|
      html << "<p>#{sentence.strip}.</p>"
    end

    self.markup = html
  end
end
