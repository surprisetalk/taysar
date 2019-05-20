defmodule Taysar.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger
  require EEx
  import Taysar.Library

  # plug Plug.Logger,
  #   log: :debug

  # plug Plug.Logger

  plug Plug.Static,
    at: "/",
    from: "static",
    only: ~w(css images fonts js sitemaps favicon.ico robots.txt)

  plug :match
  plug Plug.Parsers,
    parsers: [:json, :urlencoded],
    pass:  ["application/json"],
    json_decoder: Poison
  plug :dispatch 

  # TODO: Transform each of the template functions to accept a Map

  EEx.function_from_file :defp, :template_taysar, "templates/taysar.eex", [:title,:description,:category,:categories,:body]
  EEx.function_from_file :defp, :template_message, "templates/message.eex", [:body]

  EEx.function_from_file :defp, :template_index, "templates/index.eex", []
  get "/" do
    case get_categories() do
      {:ok, categories} ->
        page = template_taysar(
          "TAYSAR",
          "Life, software, and other garbage: the ramblings of Taylor Sarrafian.",
          nil,
          categories,
          template_index()
        )
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, page)
      {:error, reason} ->
        IO.inspect(reason)
        send_resp(conn, 500, template_taysar(nil, nil, nil, [], template_message("Something went wrong.")))
    end
  end

  EEx.function_from_file :defp, :template_routine, "templates/routine.eex", [:password,:body,:routine,:subroutines]
  get "/routine" do
    case get_categories() do
      {:ok, categories} ->
        password = conn.query_params["password"]
        %Postgrex.Result{rows: routines} = Postgrex.query!(
          Postgrex,
          """
            SELECT value FROM routines 
            WHERE created_at 
              BETWEEN DATE_TRUNC( 'day', NOW() AT TIME ZONE 'America/Los_Angeles'                    )
                  AND DATE_TRUNC( 'day', NOW() AT TIME ZONE 'America/Los_Angeles' + INTERVAL '1 day' )
            ORDER BY created_at DESC
            LIMIT 1
          """,
          []
        )
        subroutines = List.first(List.first(routines) || []) || %{
          "Frolic"     => false,
          "Grow"       => false,
          "Tidy"       => false,
          "Nothing"    => false,
          "Exercise"   => false,
          "Fuel"       => false,
          "Groom"      => false,
          "Calibrate"  => false,
          "Strategize" => false,
          "Connect"    => false,
          "Learn"      => false,
          "Create"     => false,
          "Toil"       => false,
          "Review"     => false,
          "Simplify"   => false,
          "Consume"    => false,
          "Read"       => false,
          "Sleep"      => false
        }
        page = template_taysar(
          "TAYSAR | Daily Routine",
          "Taylor Sarrafian's daily routines stats.",
          nil,
          categories,
          template_routine(
            password == System.get_env("TS_PASSWORD") && password,
            Taysar.Library.get_article!("","Daily Routine"),
            Taysar.Routine.routine,
            subroutines
          )
        )
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, page)
      {:error, reason} ->
        IO.inspect(reason)
        send_resp(conn, 500, template_taysar(nil, nil, nil, [], template_message("Something went wrong.")))
    end
  end

  post "/routine" do
    password = conn.query_params["password"]
    if password == System.get_env("TS_PASSWORD") do
      routine = Map.merge(
        %{
          "Frolic"     => false,
          "Grow"       => false,
          "Tidy"       => false,
          "Nothing"    => false,
          "Exercise"   => false,
          "Fuel"       => false,
          "Groom"      => false,
          "Calibrate"  => false,
          "Strategize" => false,
          "Connect"    => false,
          "Learn"      => false,
          "Create"     => false,
          "Toil"       => false,
          "Review"     => false,
          "Simplify"   => false,
          "Consume"    => false,
          "Read"       => false,
          "Sleep"      => false
        },
        for({k, _} <- conn.body_params, into: %{}, do: {k, true})
      )
      %Postgrex.Result{} = Postgrex.query!(
        Postgrex,
        "INSERT INTO routines (value,created_at) VALUES ($1, NOW() AT TIME ZONE 'America/Los_Angeles')",
        [routine]
      )
      conn
      |> Plug.Conn.put_resp_header("location", "/routine?password=#{password}")
      |> Plug.Conn.resp(301, "Redirecting to routine...")
    end
  end

  # TODO: POST /routine writes to DB then redirects to GET /routine

  EEx.function_from_file :defp, :template_category, "templates/category.eex", [:category,:articles]
  get "/:category" do
    case {get_categories(), get_category(category)} do
      {{:ok, categories},{:ok,articles}} ->
        description = ( articles |> Enum.join(", ") |> String.slice(0, 500) ) <> "..."
        page = template_taysar(
          "TAYSAR | " <> category,
          description,
          category,
          categories,
          template_category(category,articles)
        )
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, page)
      {{:ok, categories},{:error, :enoent}} ->
        send_resp(conn, 404, template_taysar(nil, nil, category, categories, template_message("Not found.")))
      {{:ok, categories},{:error, reason}} ->
        IO.inspect(reason)
        send_resp(conn, 500, template_taysar(nil, nil, category, categories, template_message("Something went wrong.")))
      {_,{:error, reason}} ->
        IO.inspect(reason)
        send_resp(conn, 500, template_taysar(nil, nil, category, [], template_message("Something went wrong.")))
      {{:error, reason},_} ->
        IO.inspect(reason)
        send_resp(conn, 500, template_taysar(nil, nil, category, [], template_message("Something went wrong.")))
    end
  end

  EEx.function_from_file :defp, :template_article, "templates/article.eex", [:title,:body]
  get "/:category/:title" do
    case {get_categories(), get_article(category,title)} do
      {{:ok, categories},{:ok,article}} ->
        page = template_taysar(
          "TAYSAR | " <> title,
          # TODO: get_article() should return a %{title: title,description: description}
          # TODO: For .md files, description should be all lines that don't start with a special character...
          nil,
          category,
          categories,
          template_article(title, article)
        )
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, page)
      {{:ok, categories},{:error, :enoent}} ->
        send_resp(conn, 404, template_taysar(nil, nil, category, categories, template_message("Not found.")))
      {{:ok, categories},{:error, reason}} ->
        IO.inspect(reason)
        send_resp(conn, 500, template_taysar(nil, nil, category, categories, template_message("Something went wrong.")))
      {_,{:error, reason}} ->
        IO.inspect(reason)
        send_resp(conn, 500, template_taysar(nil, nil, category, [], template_message("Something went wrong.")))
      {{:error, reason},_} ->
        IO.inspect(reason)
        send_resp(conn, 500, template_taysar(nil, nil, category, [], template_message("Something went wrong.")))
    end
  end

  # "Default" route that will get called when no other route is matched
  match _ do
    send_resp(conn, 404, template_taysar(nil, nil, nil, [], template_message("Not found.")))
  end
end

