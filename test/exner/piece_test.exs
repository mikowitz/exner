defmodule Exner.PieceTest do
  use ExUnit.Case, async: true

  alias Exner.Piece

  describe "creating new pieces" do
    test "by role" do
      assert Piece.queen(:white) == %Piece{
               role: :queen,
               color: :white
             }

      assert Piece.queen(:blue) == {:error, :invalid_piece_color, :blue}
    end

    test "by color" do
      assert Piece.white(:rook) == %Piece{
               role: :rook,
               color: :white
             }

      assert Piece.black(:jack) == {:error, :invalid_piece_role, :jack}
    end

    test "by character" do
      assert Piece.from(?q) == %Piece{
               role: :queen,
               color: :black
             }

      assert Piece.from(?K) == %Piece{
               role: :king,
               color: :white
             }

      assert Piece.from(?x) == {:error, :invalid_piece_char, ?x}
    end

    test "by string" do
      assert Piece.from("p") == %Piece{role: :pawn, color: :black}
      assert Piece.from("N") == %Piece{role: :knight, color: :white}

      assert Piece.from("X") == {:error, :invalid_piece_string, "X"}
    end
  end

  describe "place/2" do
    test "assigns a valid origin square to the piece" do
      piece = Piece.black(:pawn)

      refute piece.origin

      piece = Piece.place(piece, :d7)

      assert piece.origin == :d7
    end

    test "errors with an invalid square" do
      piece = Piece.black(:pawn)

      assert Piece.place(piece, :d9) == {:error, :invalid_square, :d9}
      assert Piece.place(piece, :x3) == {:error, :invalid_square, :x3}
    end
  end
end
