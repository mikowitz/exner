defmodule Exner.BoardTest do
  use ExUnit.Case, async: true

  alias Exner.{Board, FEN, Piece}

  describe "a new board" do
    board = Board.new()

    assert board.side_to_move == :white
    assert board.castling_rights == 15
    assert board.en_passant_square == nil
    assert board.halfmove_clock == 0
    assert board.fullmove_clock == 1

    assert length(board.pieces) == 32

    assert board.pieces[:a1] == %Piece{
             color: :white,
             role: :rook,
             origin: :a1
           }

    assert board.pieces[:g7] == %Piece{
             color: :black,
             role: :pawn,
             origin: :g7
           }

    refute board.pieces[:c3]
  end

  describe "FEN.to_fen/1" do
    test "can describe the initial state of a standard chess game" do
      board = Board.new()

      assert FEN.to_fen(board) == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    end
  end
end
