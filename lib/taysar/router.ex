defmodule Taysar.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger
  require EEx

  # plug Plug.Logger,
  #   log: :debug

  plug Plug.Logger

  plug Plug.Static,
    at: "/",
    from: "static",
    only: ~w(css images fonts js favicon.ico robots.txt)

  plug(:match)
  plug(:dispatch)

  EEx.function_from_file :defp, :template_taysar, "templates/taysar.eex", [:category,:categories,:body]
  EEx.function_from_file :defp, :template_message, "templates/message.eex", [:body]

  EEx.function_from_file :defp, :template_index, "templates/index.eex", []
  get "/" do
    case Taysar.Library.get_categories() do
      {:ok, categories} ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, template_taysar(nil, categories, template_index()))
      {:error, reason} ->
        IO.inspect(reason)
        send_resp(conn, 500, template_taysar(nil, [], template_message("Something went wrong.")))
    end
  end

  EEx.function_from_file :defp, :template_category, "templates/category.eex", [:category,:articles]
  get "/:category" do
    case {Taysar.Library.get_categories(), Taysar.Library.get_category(category)} do
      {{:ok, categories},{:ok,articles}} ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, template_taysar(category, categories, template_category(category,articles)))
      {{:ok, categories},{:error, :enoent}} ->
        send_resp(conn, 404, template_taysar(category, categories, template_message("Not found.")))
      {{:ok, categories},{:error, reason}} ->
        IO.inspect(reason)
        send_resp(conn, 500, template_taysar(category, categories, template_message("Something went wrong.")))
      {_,{:error, reason}} ->
        IO.inspect(reason)
        send_resp(conn, 500, template_taysar(category, [], template_message("Something went wrong.")))
      {{:error, reason},_} ->
        IO.inspect(reason)
        send_resp(conn, 500, template_taysar(category, [], template_message("Something went wrong.")))
    end
  end

  EEx.function_from_file :defp, :template_article, "templates/article.eex", [:body]
  get "/:category/:title" do
    case {Taysar.Library.get_categories(), Taysar.Library.get_file(category,title)} do
      {{:ok, categories},{:ok,article}} ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, template_taysar(category, categories, template_article(article)))
      {{:ok, categories},{:error, :enoent}} ->
        send_resp(conn, 404, template_taysar(category, categories, template_message("Not found.")))
      {{:ok, categories},{:error, reason}} ->
        IO.inspect(reason)
        send_resp(conn, 500, template_taysar(category, categories, template_message("Something went wrong.")))
      {_,{:error, reason}} ->
        IO.inspect(reason)
        send_resp(conn, 500, template_taysar(category, [], template_message("Something went wrong.")))
      {{:error, reason},_} ->
        IO.inspect(reason)
        send_resp(conn, 500, template_taysar(category, [], template_message("Something went wrong.")))
    end
  end

  # "Default" route that will get called when no other route is matched
  match _ do
    send_resp(conn, 404, template_taysar(nil, [], template_message("Not found.")))
  end
end

