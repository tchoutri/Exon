=====================================
Exon 2 |elixir| |license| |hexfaktor|
=====================================

Exon is a “mess manager” developed in Elixir_ and provides a simple API to manage & document your stuff. And by that I mean "physical stuff".

.. contents::
    :local:
    :depth: 3
    :backlinks: none

About the clients
~~~~~~~~~~~~~~~~~
The specs are located here_. Please tell me if something went wrong during their implementation.

About the server
~~~~~~~~~~~~~~~~

.. image:: http://i.imgur.com/8H4FoWk.png

.. image:: http://i.imgur.com/wHFpRC6.png

.. image:: http://i.imgur.com/0vEdDHE.png

Running the server.
~~~~~~~~~~~~~~~~~~~

(export MIX_ENV=prod)

1. Edit the [config file](config/config.exs) according to your needs.
2. ``mix do deps.get, compile``
3. ``mix ecto.migrate``
4. ``iex -S mix`` or ``iex -S mix phoenix.server`` to enable the WebUI
5. ???
6. Enjoy.


What should be done
~~~~~~~~~~~~~~~~~~~

- AUTH!!!
    - an ``auth`` command and SSL.
- Writing tests.
- ☑️ Returning the ID of the newly-created entry in the database.
- ☑️ Open an issue on Combine because it is not happy to receive some non-ASCII characters, such as “,”,Ë…
- ☑️ Organise the transition to SQlite
    - ☑️ Ability to add comments?
- ☑️Implement QRCode generation (I found the lib!)
    - ☑️Don't forget 404 on non-existing items.
- Make it more CRUD
    * For the moment, every comment and item are stored *ad vitam æternam*
    * Every user has to be truste.
- A search functionality
    - FTS4 ?
    - ``LIKE`` ?


.. _Elixir: http://elixir-lang.org
.. _here: specs.md


.. |elixir| image:: https://cdn.rawgit.com/tchoutri/Exon/master/elixir.svg
            :target: http://elixir-lang.org
            :alt: Made in Elixir
.. |license| image:: https://img.shields.io/badge/license-MIT-blue.svg
             :target: https://opensource.org/licenses/MIT 
             :alt: MIT License
.. |hexfaktor| image:: https://beta.hexfaktor.org/badge/all/github/tchoutri/Exon.svg
               :target: https://beta.hexfaktor.org/github/tchoutri/Exon
               :alt: Dependencies status
