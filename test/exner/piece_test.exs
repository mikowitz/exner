defmodule Exner.PieceTest do
  use ExUnit.Case, async: true

  alias Exner.{FEN, Piece}

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

  describe "default_starting_positions/0" do
    test "generates placed pieces for the opening position of a game of regular chess" do
      pieces = Piece.default_starting_positions()

      assert pieces[:a2] == %Piece{role: :pawn, color: :white, origin: :a2}
      assert pieces[:f8] == %Piece{role: :bishop, color: :black, origin: :f8}
    end
  end

  describe "to_fen/1" do
    test "returns the FEN notation for the piece" do
      assert FEN.to_fen(Piece.white(:king)) == "K"
      assert FEN.to_fen(Piece.white(:queen)) == "Q"
      assert FEN.to_fen(Piece.white(:rook)) == "R"
      assert FEN.to_fen(Piece.white(:bishop)) == "B"
      assert FEN.to_fen(Piece.white(:knight)) == "N"
      assert FEN.to_fen(Piece.white(:pawn)) == "P"

      assert FEN.to_fen(Piece.black(:king)) == "k"
      assert FEN.to_fen(Piece.black(:queen)) == "q"
      assert FEN.to_fen(Piece.black(:rook)) == "r"
      assert FEN.to_fen(Piece.black(:bishop)) == "b"
      assert FEN.to_fen(Piece.black(:knight)) == "n"
      assert FEN.to_fen(Piece.black(:pawn)) == "p"
    end
  end
end
