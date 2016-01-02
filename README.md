Exon 2 [![Elixir](https://cdn.rawgit.com/tchoutri/Exon/master/elixir.svg)](http://elixir-lang.org) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
====

Exon is a “mess manager” developed in [Elixir](http://elixir-lang.org) and provides a simple API to manage & document your stuff.

### About the clients
The specs are located [here](specs.md). Please tell me if something went wrong during their implementation. <3.


## About the server

![Starting](http://i.imgur.com/8H4FoWk.png)

![Home](http://i.imgur.com/ZOMapRf.png)

![Form](http://i.imgur.com/Uc3IIiz.png)

![Already Registered](http://i.imgur.com/IvzzlMN.png)

![New Item](http://i.imgur.com/7ZoedQb.png)

### Running the server.

(export MIX_ENV=prod)

1. Edit the [config file](config/config.exs) according to your needs.
2. `mix do deps.get, compile`
3. `mix ecto.migrate`
4. `iex -S mix` or `iex -S mix phoenix.server` to enable the WebUI
5. ???
6. Enjoy.


### What should be done

- [ ] Writing tests.
- [x] Returning the ID of the newly-created entry in the database.
- [x] Open an issue on sqlite_ecto about the modification of the :comments field
- [x] Open an issue on Combine because it is not happy to receive some non-ASCII characters, such as “,”,Ë…

### What should be done

- [x] Organise the transition to SQlite
    - [x] Ability to add comments?
- [x] Implement QRCode generation (I found the lib!)
    - [x] Don't forget 404 on non-existing items.
    - [ ] Generating a unique key for each item in its URL.
