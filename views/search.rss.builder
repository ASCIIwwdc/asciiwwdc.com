xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title %(ASCIIwwdc Search Results for "#{@query}")
    xml.description "#{@sessions.count} #{@sessions.count == 1 ? "Result" : "Results"}"

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
  end
end
