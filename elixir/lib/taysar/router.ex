defmodule Taysar.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger
  require EEx

  plug Plug.Logger,
    log: :debug

  plug Plug.Static,
    at: "/",
    from: "static",
    only: ~w(css images fonts js favicon.ico robots.txt)

  plug(:match)
  plug(:dispatch)

  EEx.function_from_file :defp, :template_taysar, "templates/taysar.eex", [:category,:categories,:body]

  EEx.function_from_file :defp, :template_index, "templates/index.eex", []
  get "/" do
    categories = Map.keys( Taysar.Library.all() )
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, template_taysar(nil,categories,template_index()))
       # TODO: Use README.md!
  end

  EEx.function_from_file :defp, :template_category, "templates/category.eex", [:category,:articles]
  get "/:category" do
    categories = Map.keys( Taysar.Library.all() )
    case Map.fetch( Taysar.Library.all(), category ) do
      {:ok,articles} ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, template_taysar(category,categories,template_category(category,Map.keys(articles))))
      :error ->
        conn
        |> send_resp(404, "not found")
    end
  end

  EEx.function_from_file :defp, :template_article, "templates/article.eex", [:category,:title,:body]
  get "/:category/:title" do
    categories = Map.keys( Taysar.Library.all() )
    case Taysar.Library.get_body(category,title) do
      {:ok,body} ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, template_taysar(category,categories,template_article(category,title,body)))
      :error ->
        conn
        |> send_resp(404, "not found")
    end
  end

  # # Simple GET Request handler for path /hello
  # get "/hello" do
  #   send_resp(conn, 200, Taysar.hello())
  #   # send_resp(conn, 200, "world")
  # end

  # # Basic example to handle POST requests wiht a JSON body
  # post "/post" do
  #   {:ok, body, conn} = read_body(conn)
  #   body = Poison.decode!(body)
  #   IO.inspect(body)
  #   send_resp(conn, 201, "created: #{get_in(body, ["message"])}")
  # end

  # "Default" route that will get called when no other route is matched
  match _ do
    send_resp(conn, 404, "not found")
  end
end

