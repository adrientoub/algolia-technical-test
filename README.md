# README

## Requirements

For this code to work you need:
* Ruby 2.3.0 or greater (tested on Ruby 2.4.0)
* `bundler` for gem installation

## Data

For this server to work you need to have a file named `hn_logs.tsv` containing
a date (of the form 'YYYY-MM-DD HH-mm-ss'), a tabulation and a query.

## Quick start

To launch the server just go in the root of the repository and run:

```sh
bundle install --deployment # will install any gems needed for the project
rackup # will launch the server
```

You can then use any `rackup` option to set parameters to the server. For
instance you can use `rackup -p 3000 -o 0.0.0.0` to launch the server on the
port `3000` (default `9292`) and listening on `0.0.0.0` (default `localhost`).

## Requests

The server implements two routes:

* `GET /1/queries/count/<DATE_PREFIX>` which returns a JSON object specifying
the number of distinct queries that have been done during a specific time range
* `GET /1/queries/popular/<DATE_PREFIX>?size=<SIZE>` which returns a JSON object
listing the top <SIZE> popular queries that have been done during a specific
time range

## Data structure

The data structure behind this server is a prefix tree containing the prefix
of the dates of each requests. For simplicity, here the tree nodes are listed
using Ruby's Hash data structure.
