require 'ostruct'

class Session < Sequel::Model
  plugin :json_serializer, naked: true, except: [:id, :tsv]
  plugin :validation_helpers
  plugin :typecast_on_load, :annotations, :timecodes
  plugin :schema

  def self.search(query, year = nil)
    query = Session.db.literal(query.to_s)
    year = Session.db.literal(year.to_i) if year

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
               #{%{AND year = #{year}} if year}
             ORDER BY rank DESC
    }].collect{|result| OpenStruct.new(result)}
  end

  def transcribed?
    self.transcript and not ("false" === self.transcript or self.transcript.empty?)
  end

  def to_s
    "#{self.number} #{self.title}"
  end

  def validate
    super

    validates_presence [:title, :description, :year, :track]
    validates_unique [:title, :year]
    validates_unique [:number, :year]
  end

  def before_save
    super

    html = ""
    if self.annotations and not self.annotations.empty?
      self.transcript = self.annotations.join("\n\n")

      paragraphs = []
      current_paragraph = ""
      self.annotations.each_with_index do |annotation, index|
        next if annotation.empty?

        timecode = self.timecodes[index]

        open = timecode ? %{<span id="t=#{timecode}" data-timecode="#{timecode}">} : %{<span>}
        close = %{</span> }

        current_paragraph << [open, annotation, close].join("")
        case annotation
        when /^\[.+\]$/
          paragraphs << [%{<p class="annotation">}, current_paragraph, %{</p>}].join("")
          current_paragraph = ""
        when /\.\?\!$/
          paragraphs << [%{<p>}, current_paragraph, %{</p>}].join("")
          current_paragraph = ""
        end
      end

      html = paragraphs.uniq.join("\n")
    elsif self.transcript
      self.transcript.split(/\.\s+/).each do |sentence|
        html << %{<p>#{sentence.strip}.</p>}
      end
    end

    self.markup = html
  end
end
