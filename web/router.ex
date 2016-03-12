defmodule Exon.Router do
  use Exon.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Exon do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/about", PageController, :about
    get "/item/:id", PageController, :id # *TODO* : This should not return raw JSON. Let's check it with the headesr.
    get "/item/:id/qrcode", PageController, :qrcode
  end

  scope "/form", Exon do
    pipe_through :browser

    get "/", FormController, :index
    get "/", FormController, :index
  end
end
