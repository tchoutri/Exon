=====================================
Exon 2 |elixir| |license| |hexfaktor|
=====================================

Exon is a “mess manager” developed in Elixir_ and provides a simple API to manage & document your stuff. And by that I mean "physical stuff".

.. contents::
    :local:
    :depth: 1 
    :backlinks: none

About the clients
~~~~~~~~~~~~~~~~~
The specs are located here_. Please tell me if something went wrong during their implementation.

About the server
~~~~~~~~~~~~~~~~

.. image:: http://i.imgur.com/8H4FoWk.png
           :width: 33%

.. image:: http://i.imgur.com/wHFpRC6.png
           :width: 33%

.. image:: http://i.imgur.com/0vEdDHE.png
           :width: 33%

Running the server.
~~~~~~~~~~~~~~~~~~~

(``export MIX_ENV=prod``)

1. Edit the `config file` ) according to your needs.
2. ``mix do deps.get, compile``
3. ``mix ecto.migrate``
4. ``iex -S mix`` or ``iex -S mix phoenix.server`` to enable the WebUI
5. ???
6. Enjoy.


What should be done
~~~~~~~~~~~~~~~~~~~

- Authentication_
- Writing tests.
- Make it more CRUD
    * For the moment, every comment and item are stored *ad vitam æternam*
    * Every user has to be truste.
- A search functionality
    - FTS4 ?
    - ``LIKE`` ?


Authentication
##############

I am exploring my options about how to implement an authentication system for Exon.
It should be implementing the architecture goals (mostly taken from OWASP's `Guide to Authentication`_):

* Credentials transmitted over an encrypted link (thanks ``stunnel``)
* Hashing and Salting
* Returning the date & time of last time they logged in
* Enforce password complexity
* Password should be easy to change
* Only return “Login failed; Invalid userID or password” in case of login failure
* Don't rely on the client's IP address / hostname because they can be faked/spoofed.



.. _Elixir: http://elixir-lang.org
.. _here: specs.md
.. _`config file`: config/config.exs
.. _`Guide to Authentication`: https://www.owasp.org/index.php/Guide_to_Authentication


.. |elixir| image:: https://cdn.rawgit.com/tchoutri/Exon/master/elixir.svg
            :target: http://elixir-lang.org
            :alt: Made in Elixir
.. |license| image:: https://img.shields.io/badge/license-MIT-blue.svg
             :target: https://opensource.org/licenses/MIT 
             :alt: MIT License
.. |hexfaktor| image:: https://beta.hexfaktor.org/badge/all/github/tchoutri/Exon.svg
               :target: https://beta.hexfaktor.org/github/tchoutri/Exon
               :alt: Dependencies status
