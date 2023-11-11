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

  describe "shift/2" do
    test "shifts a square by the given delta" do
      assert Square.shift(:a2, {2, 1}) == :c3
    end

    test "returns nil if the movement is off the board" do
      assert Square.shift(:a2, {-1, 0}) == {:error, :invalid_shift, {:a2, {-1, 0}}}
    end
  end
end
