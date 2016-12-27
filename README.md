# README

## Requirements

For this code to work you need:
* Ruby 2.3.0 or greater (tested on Ruby 2.4.0)
* `bundler` for gem installation

## Quick start

To launch the server just go in the root of the repository and run:

```sh
bundle install --deployment # will install any gems needed for the project
rackup # will launch the server
```

You can then use any `rackup` option to set parameters to the server. For
instance you can use `rackup -p 3000` to launch the server on the port 3000.

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
