defmodule ExodusTest do
  use ExUnit.Case
  doctest Exodus

  test "greets the world" do
    assert Exodus.hello() == :world
  end
end
