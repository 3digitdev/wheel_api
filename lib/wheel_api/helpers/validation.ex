defmodule WheelApi.Validation do
    @spec error_response([String.t()] | String.t()) :: String.t()
    def error_response(errors) when is_list(errors), do: Poison.encode!(%{errors: errors})
    def error_response(error) when is_binary(error), do: Poison.encode!(%{error: error})

    def success_response(data, key), do: Poison.encode!(%{key => data})

    @spec changeset_to_error_list(%Ecto.Changeset{}) :: [String.t()] | nil
    def changeset_to_error_list(changeset) do
        case changeset.errors do
            [] -> {:ok, changeset}
            errors ->
                error_map = Enum.into(errors, %{})
                {:error, error_map
                    |> Map.keys
                    |> Enum.map(fn k ->
                        {v, _} = Map.get(error_map, k)
                        "'#{k}' #{v}"
                    end)
                }
        end
    end
end
