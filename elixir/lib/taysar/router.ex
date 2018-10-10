defmodule Taysar.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger

  plug(Plug.Logger, log: :debug)

  plug(:match)
  plug(:dispatch)

  # Simple GET Request handler for path /
  get "/" do
    page_contents = EEx.eval_file("templates/index.eex", [])
    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(200, page_contents)
  end

  # Simple GET Request handler for path /hello
  get "/hello" do
    send_resp(conn, 200, Taysar.hello())
    # send_resp(conn, 200, "world")
  end

  # Basic example to handle POST requests wiht a JSON body
  post "/post" do
    {:ok, body, conn} = read_body(conn)
    body = Poison.decode!(body)
    IO.inspect(body)
    send_resp(conn, 201, "created: #{get_in(body, ["message"])}")
  end

  # "Default" route that will get called when no other route is matched
  match _ do
    send_resp(conn, 404, "not found")
  end
end

