# ASCIIwwdc
*Searchable full-text transcripts of WWDC sessions*

Find the content you've been looking for, without having to scrub through session videos. Created by normalizing and indexing video transcript files provided for WWDC videos.

## Workflow Integration

- [`wwdc` Command-Line Interface](https://github.com/ASCIIwwdc/wwdc)

```bash
$ wwdc info 228

    228: "Hidden Gems in Cocoa and Cocoa Touch"
    Learn from the experts about the Cocoa and Cocoa Touch classes you may not even know exist, as well as some very obscure but extremely valuable classes that are favorites of the presenters.
```

- [Alfred Web Search](https://gist.github.com/mattt/6756058)
- [DEVONagent Plugin](https://github.com/annard/DEVONagent-Plugins)
- [Quix Plugin](https://github.com/rydermackay/quixconfig/blob/master/config.txt)

## Webservice APIs

### Session Information

```bash
curl -i -X GET -H "Accept: application/json" "https://asciiwwdc.com/2013/sessions/228"
```

### Search

```bash
curl -i -X GET -H "Accept: application/json" "https://asciiwwdc.com/search?q=UIView"
```

---

## Requirements

- [Heroku Toolbelt](https://toolbelt.heroku.com)
- Ruby 1.9+ with [Bundler](http://bundler.io)
- Postgres 9.2+ ([Postgres.app](http://postgresapp.com/) is the easiest way to get a Postgres server running on your Mac)

## Setup

```bash
$ git clone https://github.com/mattt/asciiwwdc.com.git --recursive
$ cd asciiwwdc.com
$ bundle
$ createdb asciiwwdc && echo "DATABASE_URL=postgres://localhost/asciiwwdc" > .env
$ foreman run bundle exec rake db:seed     # can take a year parameter, eg [2015]
$ foreman start
```

## Deploying to Heroku

[Heroku](https://www.heroku.com) is the easiest way to get your app up and running. For full instructions on how to get started, check out ["Getting Started with Ruby on Heroku"](https://devcenter.heroku.com/articles/getting-started-with-ruby).

Once you've installed the [Heroku Toolbelt](https://toolbelt.heroku.com), and [have a Heroku account](https://id.heroku.com/signup/), enter the following commands from the project directory:

```bash
$ heroku create
$ git push heroku master
```

## Contact

Mattt ([@mattt](https://twitter.com/mattt))

- https://github.com/ASCIIwwdc
- https://twitter.com/ASCIIwwdc

## License

WWDC is available under the MIT license. See the LICENSE file for more info.

All content copyright © 2010 – 2018 Apple Inc. All rights reserved.
