defmodule TaysarTest do
  use ExUnit.Case
  doctest Taysar

  test "greets the world" do
    assert Taysar.hello() == :world
  end
end
