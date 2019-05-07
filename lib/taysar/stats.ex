defmodule Taysar.Stats do

  use GenServer

  ##############################################################################

  defstruct contributors: nil

  ##############################################################################

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(_) do
    fetch()
    # poll()
    {:ok, %Taysar.Stats{}}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:fetch, state) do
    # https://coderstats.net/github/#surprisetalk
    # https://developer.github.com/v3/repos/statistics/
      # /repos/:owner/:repo/stats/contributors
      # /repos/:owner/:repo/stats/commit_activity
      # /repos/:owner/:repo/stats/code_frequency
      # /repos/:owner/:repo/stats/participation
      # /repos/:owner/:repo/stats/punch_card

    # consider crawling the repo 

    # actually, just commit the arbttt stats to a repo and make an endpoint to manually git pull

    # or make a polling task that git pulls every few minutes

    {:noreply, state}
  end

  ##############################################################################

  # defp poll() do
  #   receive do
  #   after
  #     3_600_000 ->
  #       fetch()
  #       poll()
  #   end
  # end

  def get do
    GenServer.call(__MODULE__, :get)
  end
  
  def fetch do
    GenServer.cast(__MODULE__, :fetch)
  end

end

