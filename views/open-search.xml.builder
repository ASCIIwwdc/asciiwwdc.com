xml.instruct!
xml.OpenSearchDescription "xmlns" => "http://a9.com/-/spec/opensearch/1.1/" do
    xml.ShortName "ASCIIwwdc Search"
    xml.Description "Find the content you're looking for, without scrubbing through videos."
    xml.Contact "mattt@nshipster.com"
    xml.Attribution "All content copyright © 2010 – 2019 Apple Inc. All rights reserved."
    xml.Query "role" => "example", "searchTerms" => "NSHipster"
    xml.URL "type" => "application/rss+xml",
            "template" => "https://asciiwwdc.com/search.rss?q={searchTerms}"
    xml.Language "en-us"
    xml.OutputEncoding "UTF-8"
    xml.InputEncoding "UTF-8"
end
