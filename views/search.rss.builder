# frozen_string_literal: true

xml.instruct! :xml, version: '1.0'
xml.rss :version => '2.0', 'xmlns:openSearch' => 'http://a9.com/-/spec/opensearch/1.1/' do
  xml.channel do
    xml.title %(ASCIIwwdc Search Results for "#{@query}")
    xml.description "#{@sessions.count} #{@sessions.count == 1 ? 'Result' : 'Results'}"

    @sessions.each do |session|
      xml.item do
        xml.title session.title
        xml.description do
          xml.cdata! session.excerpt
        end
        xml.link url(session) + "?q=#{@query}"
        xml.guid url(session)
      end
    end
    
    xml.tag! 'openSearch:totalResults', @sessions.count
    xml.tag! 'openSearch:startIndex', 1
    xml.tag! 'openSearch:itemsPerPage', @sessions.count
  end
end
