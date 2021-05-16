defmodule WheelApi.TestWheel do
    use ExUnit.Case

    import Mock

    test "exists passes result from Ecto" do
        with_mock WheelApi.Repo, [exists?: fn(_) -> true end] do
            assert WheelApi.Wheel.exists?(1)
            assert called WheelApi.Repo.exists?(:_)
        end
    end
end
