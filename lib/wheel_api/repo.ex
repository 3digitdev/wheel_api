defmodule WheelApi.Repo do
  use Ecto.Repo,
    otp_app: :wheel_api,
    adapter: Ecto.Adapters.MyXQL
end
