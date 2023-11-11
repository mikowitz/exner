defmodule Exner.MoveTest do
  use ExUnit.Case, async: true

  alias Exner.Move

  describe "from_pgn/2" do
    test "a simple pawn move" do
      assert Move.from_pgn("e4", :white) == %Move{
               color: :white,
               role: :pawn,
               to: :e4,
               original: "e4"
             }
    end

    test "a simple capture" do
      assert Move.from_pgn("Nxd3", :black) == %Move{
               color: :black,
               role: :knight,
               to: :d3,
               original: "Nxd3",
               capture: true
             }
    end

    test "castling" do
      assert Move.from_pgn("O-O", :white) == %Move{
               color: :white,
               original: "O-O",
               castle: :kingside
             }
    end

    test "check" do
      assert Move.from_pgn("Rac3+", :black) == %Move{
               color: :black,
               role: :rook,
               original: "Rac3+",
               to: :c3,
               from: "a",
               check: :check
             }
    end

    test "promotion" do
      assert Move.from_pgn("h8=Q", :white) == %Move{
               color: :white,
               role: :pawn,
               original: "h8=Q",
               to: :h8,
               promotion: :queen
             }
    end
  end
end
