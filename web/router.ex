defmodule Discuss.Router do
  use Discuss.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Discuss.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Discuss do
    pipe_through :browser # Use the default browser stack

    get "/", TopicController, :index
    get "/topics/new", TopicController, :new
    
    get "/topics/:id/edit", TopicController, :edit
    get "/topics/:id", TopicController, :show

    post "/topics", TopicController, :create
    post "/topics/:id", TopicController, :create_comment
    
    
    put "/topics/:id", TopicController, :update
    
    delete "/topics/:id", TopicController, :delete
  end

  scope "/auth", Discuss do
    pipe_through :browser

    get "/logout", AuthController, :logout
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", Discuss do
  #   pipe_through :api
  # end
end
