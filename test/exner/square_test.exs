defmodule Exner.SquareTest do
  use ExUnit.Case, async: true

  alias Exner.Square

  describe "is_valid?/1" do
    test "returns whether a square name is a valid square on the chessboard" do
      assert Square.is_valid?(:a1)
      assert Square.is_valid?(:h8)
      assert Square.is_valid?(:a4)
      assert Square.is_valid?(:b3)

      refute Square.is_valid?(:a9)
      refute Square.is_valid?(:i3)
    end
  end
end
