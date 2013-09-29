# ASCIIwwdc
*Searchable full-text transcripts of WWDC sessions*

## Development setup

To run the app locally you'll need a PostgreSQL database. Assuming you're on OS
X, the easiest way to start is to grab and install [Postgres.app]
(http://postgresapp.com/). Once you've installed this and started the app,
you'll want to do the following:

* Clone the repository using the `--recursive` option and `cd` into the project
dir
* Run `bundle install` to install dependencies
* Run `psql -h localhost` to connect to your local PostgreSQL instance
* Create a new database with the command `CREATE DATABASE asciiwwdc;` (or use a
name of your choosing). Quit the client with `\q`
* Set a `DATABASE_URL` enviroment variable to point to your local PostgreSQL
instance, e.g. `export DATABASE_URL=postgres://localhost/asciiwwdc`
* Run `rake db:seed` to load data into your local DB

To actually run the server, just say `rackup config.ru`!
