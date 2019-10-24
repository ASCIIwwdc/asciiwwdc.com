# frozen_string_literal: true

xml.instruct!
xml.OpenSearchDescription 'xmlns' => 'http://a9.com/-/spec/opensearch/1.1/',
                          'xmlns:moz' => 'http://www.mozilla.org/2006/browser/search/' do
  xml.ShortName 'ASCIIwwdc'
  xml.Image 'https://asciiwwdc.com/favicon.ico',
            'type' => 'image/x-icon',
            'width' => '16',
            'height' => '16'
  xml.Description "Searchable full-text transcripts of WWDC sessions."
  xml.Contact "mattt@nshipster.com"
  xml.Attribution 'All content copyright © 2010 – 2019 Apple Inc. All rights reserved.'
  xml.Query 'role' => 'example', 'searchTerms' => 'Swift'
  xml.Url 'type' => 'application/opensearchdescription+xml',
          'rel' => 'self',
          'template' => 'https://asciiwwdc.com/open-search.xml'
  xml.URL 'type' => 'application/rss+xml',
          'template' => 'https://asciiwwdc.com/search.rss?q={searchTerms}'
  xml.URL 'type' => 'text/html',
          'method' => 'GET',
          'template' => 'https://asciiwwdc.com/search?q={searchTerms}'
  xml.Language 'en-us'
  xml.OutputEncoding 'UTF-8'
  xml.InputEncoding 'UTF-8'
  xml.tag! 'moz:SearchForm', 'https://asciiwwdc.com/'
end
