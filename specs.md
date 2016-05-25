Protocol Specifications
=======================

Introduction
--------

Exon is what can be called a “mess manager”. By "mess" I mean "A situation when an undefined number of objects are lying around and not scrupulously
documented, in their purpose or their current state of existence".
Exon is therefore an item recording system that aims to provide a unified interface (API) for people who would like to fetch informations about those
abovementionned objects.

Protocol
--------

### Sending messages

Exon's API is based on UTF-8-encoded character strings above [TCP/IP](https://en.wikipedia.org/wiki/Internet_protocol_suite).
You can talk to the API by sending `messages` that are made of `commands`, `subcommands`, `keys` and `values`.
The separator between `commands`, `subcommands` and `key/value` blocks is a space, whereas key=value blocks are separated with `::`

There are for the moment a limited number of possible `commands` and `subcommands`:

* `id`

* `add` which takes the following keys:
    * `name="Name of the item"`
    * `comments="Comments about the item"`

* `comment` which takes the following keys:
    * `id=ID` with ID being a natural integer strictly greater than 0 between two double quotes
    * `comments="Another comment"`.

* A `message` requesting informations about a particular ID uses the `id` commandwill say:

`id <ID>`

* A `message` adding a new item to the database will say:

`add new name="Fusion engine"::comments="Could explode at any time."`

* A `message` adding a new comment to a particular item will say:

`add comment id="1"::comments="this is another comment"`

### Receiving messages
Now it's getting a bit more funky. Due to an obvious will of interoperability with the rest of the world, the API response is UTF-8-encoded and in JSON.
Yes, it uses JSON for the server-client protocol.

#### ID request
The fields of the JSON document are the following: `name`, `id`, `date` and `comments`.


```JSON
{
  "status": "success",
  "message": "Item is available.",
  "data": {
    "name": "Engine",
    "id": 1,
    "date": "2015-12-29 00:12:04",
    "comments": "May explode."
  }
}
```
As you can see in the abovementionned example, most of the values are character strings, except for `id` which returns an integer. The `date` field will return a
the date as it is returned by the command `date "+%G-%m-%d %H:%M:%S"` on UNIX-like systems.

#### Item registering

When registering a new item with the `add new` message, Exon will send this response:

```JSON
{
  "status": "success",
  "message": "New item registered",
  "data": "ID"
}
```

#### Adding a new comment

When adding a new comment to an ID, Exon will send the following JSON document:

```JSON
{
  "status": "success",
  "message": "New comment added.",
  "data": {
    "name": "Engine",
    "id": 1,
    "date": "",
    "comments": "BOOM!"
  }
}
```
Or if it fails, this:

```JSON
{
  "status": "error",
  "message": "error message",
  "data": null
}
```

### The worst that could happen

#### Wrong item ID

If you request a wrong item number, let's say 5, Exon will answer with the following JSON document:

```JSON
{
  "status": "error",
  "message": "Item not found.",
  "data": {
    "name": "",
    "id": 5,
    "date": "",
    "comments": ""
  }
}
```
#### Duplicate item

If you try to register an item with the same name as a previous one, the following JSON document will be sent

```JSON
{
  "status": "error",
  "message": "Item already exists",
  "data": 1
}
```
#### Protocol error

If Exon didn't understand the `message`, it will send the following following JSON document

```JSON
{
  "status": "error",
  "message": "Protocol error, please refer to the documentation",
  "data": null
}
```

And in the worst case, the server crashes and you are invited to open an issue on GitHub.

