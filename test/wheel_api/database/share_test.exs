defmodule WheelApi.TestShare do
    use ExUnit.Case

    import Mock

    setup do
        blank_share = %WheelApi.Share{}
        %{blank_share: blank_share}
    end

    test "get_all passes result from Ecto", %{blank_share: expected} do
        with_mock WheelApi.Repo, [all: fn(_) -> [expected] end] do
            assert WheelApi.Share.get_all == [expected]
            assert called WheelApi.Repo.all(:_)
        end
    end

    test "get_all with limit passes result from Ecto", %{blank_share: expected} do
        with_mock WheelApi.Repo, [all: fn(_) -> [expected] end] do
            assert WheelApi.Share.get_all(1) == [expected]
            assert called WheelApi.Repo.all(:_)
        end
    end

    test "get_single returns object from Ecto if exists", %{blank_share: expected} do
        with_mock WheelApi.Repo, [get: fn(_, _) -> expected end] do
            assert WheelApi.Share.get_single(1) == {:ok, expected}
            assert called WheelApi.Repo.get(WheelApi.Share, 1)
        end
    end

    test "get_single returns error from Ecto if not exists" do
        with_mock WheelApi.Repo, [get: fn(_, _) -> :nil end] do
            assert WheelApi.Share.get_single(1) == :error
            assert called WheelApi.Repo.get(WheelApi.Share, 1)
        end
    end

    test "buy_shares returns error if Wheel doesn't exist" do
        with_mock WheelApi.Wheel, [exists?: fn(_) -> false end] do
            assert WheelApi.Share.buy_shares(1, 1, 1.0, ~D[2000-01-01]) == :error
            assert called WheelApi.Wheel.exists?(1)
        end
    end

    test "buy_shares returns error if Wheel exists but insert fails" do
        with_mocks [
            {WheelApi.Wheel, [], [exists?: fn(_) -> true end]},
            {WheelApi.Repo, [], [insert: fn(_) -> {:error, "bad"} end]}
        ] do
            assert WheelApi.Share.buy_shares(1, 1, 1.0, ~D[2000-01-01]) == :error
            assert called WheelApi.Wheel.exists?(1)
            assert called WheelApi.Repo.insert(:_)
        end
    end
end
