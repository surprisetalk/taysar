defmodule Taysar.Library do

  use GenServer

  require Tentacat

  require HTTPoison

  # Client

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def all do
    GenServer.call(__MODULE__, :all)
  end

  def all(pid) do
    GenServer.call(pid, :all)
  end

  def get_category(category) do
    GenServer.call(__MODULE__, {:get_category,category})
  end

  def get_body(category,title) do
    GenServer.call(__MODULE__, {:get_body,category,title})
  end

  # def push(pid, item) do
  #   GenServer.cast(pid, {:push, item})
  # end

  # def pop(pid) do
  #   GenServer.call(pid, :pop)
  # end

  # Server (callbacks)

  defp find!( path \\ "" ) do
    {200, data, _response} = Tentacat.Contents.find( "surprisetalk", "writings", path )
    data
  end

  defp apply_merge( maps ) do
    maps
    |> Enum.reduce( &Map.merge/2 )
  end

  @impl true
  def init(_args \\ []) do
    shelves = apply_merge( for %{ "name" => category } <- find!() do
        %{ category => apply_merge( for %{ "download_url" => downloadUrl, "name" => title } <- find!( category ),
                           %{body: body} = HTTPoison.get!( downloadUrl ) do
             %{ title => body }       
           end )
         }
    end )
    {:ok, shelves}
  end

  @impl true
  def handle_call(:all, _from, all) do
    {:reply, all, all}
  end

  @impl true
  def handle_call({:get_category,category}, _from, all) do
    {:reply, Map.fetch( all, category ), all}
  end

  @impl true
  def handle_call({:get_body,category,title}, _from, all) do
    body = case Map.fetch( all, category ) do
      {:ok,category_} ->
        Map.fetch( category_, title )
      :error ->
        :error
    end
    {:reply, body, all}
  end

  # @impl true
  # def handle_call(:pop, _from, [head | tail]) do
  #   {:reply, head, tail}
  # end

  # @impl true
  # def handle_cast({:push, item}, state) do
  #   {:noreply, [item | state]}
  # end
end