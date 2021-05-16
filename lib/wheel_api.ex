defmodule WheelApi do
  use Application

  @moduledoc """
  Documentation for `WheelApi`.
  """

  @impl true
  def start(_type, _args) do
    WheelApi.Supervisor.start_link(name: WheelApi.Supervisor)
  end
end
