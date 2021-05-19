# WheelApi

### Requirements

- MySQL
- Elixir + Erlang Runtime

### Environment Variables

- `WHEEL_API_DB_NAME`:  The name of the database to point to
- `WHEEL_API_DB_USER`:  The username to log into the DB with
- `WHEEL_API_DB_PASS`:  The password to use to log into the DB
- `WHEEL_API_DB_HOST`:  The hostname to use for the DB (`"localhost"` for local testing)
- `WHEEL_API_SECRET`:   The expected API Key from hosts to connect  (yes I know this sucks as a solution, shut up)

### Instructions

1. Build the Database with `mix ecto.create`
2. Build all the tables with `mix ecto.migrate`
3. For local use, start the application with `iex -S mix`

The API (**WIP**) can be found at `http://localhost:4000`

In `IEX`, you can run commands from `lib/wheel_api/database` modules to perform actions on the DB.

_TODO: Deployment_

https://blog.lelonek.me/minimal-elixir-http2-server-64188d0c1f3a
