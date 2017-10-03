==============================================
Exon 2 |travis| |elixir| |license| |hexfaktor|
==============================================

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

.. image:: http://i.imgur.com/1yCKF0n.png
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

Logging
~~~~~~~

For the moment (16/09/2016), partial logging on disk is done, at `log/exon.log`. It contains the date + hour of the operation, the result (success/failure)
and the client's username + hostname/IP address.

What should be done
~~~~~~~~~~~~~~~~~~~

- Authentication_
- Writing tests.
- Make it more CRUD
    * For the moment, every comment and item are stored *ad vitam æternam*
- A search functionality
    * Use LIKE.


Authentication
##############

An authenticated user can register items with their name, and are able to remove items.

TODO:

* In case of repetedly login failure, activate a timeout_ and a ban.


Trivia
######

    {:ok, socket} = :gen_tcp.connect {127,0,0,1}, 8878, [:binary, active: false]
    :ok = :gen_tcp.send(socket, "id 324234\n")
    {:ok, json} = :gen_tcp.recv(socket, 0)

.. _Elixir: http://elixir-lang.org
.. _here: specs.rst
.. _`config file`: config/config.exs
.. _`Guide to Authentication`: https://www.owasp.org/index.php/Guide_to_Authentication
.. _timeout: https://www.owasp.org/index.php/Guide_to_Authentication#Suggested_Timeouts
.. _FTS5: https://sqlite.org/fts5.html

.. |travis| image:: https://travis-ci.org/tchoutri/Exon.svg?branch=master
		    :target: https://travis-ci.org/tchoutri/Exon
		    :alt: Travis CI build on Master branch

.. |elixir| image:: https://cdn.rawgit.com/tchoutri/Exon/master/elixir.svg
            :target: http://elixir-lang.org
            :alt: Made in Elixir
.. |license| image:: https://img.shields.io/badge/license-MIT-blue.svg
             :target: https://opensource.org/licenses/MIT 
             :alt: MIT License
.. |hexfaktor| image:: https://beta.hexfaktor.org/badge/all/github/tchoutri/Exon.svg
               :target: https://beta.hexfaktor.org/github/tchoutri/Exon
               :alt: Dependencies status
