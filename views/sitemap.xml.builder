xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc "https://asciiwwdc.com/"
    xml.priority 1.0
  end

  @sessions.each do |session|
    xml.url do
      xml.loc url(session)
    end
  end
end
