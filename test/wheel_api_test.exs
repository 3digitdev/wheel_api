defmodule WheelApiTest do
  use ExUnit.Case
  doctest WheelApi

  test "greets the world" do
    assert WheelApi.hello() == :world
  end
end
