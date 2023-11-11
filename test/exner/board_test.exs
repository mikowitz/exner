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

  describe "move/3" do
    test "will not let the wrong player move" do
      board = Board.new()

      assert Board.move(board, "e6", :black) == {:error, :wrong_side_to_move, :black}
    end

    test "will allow and handle a valid move" do
      board =
        Board.new()
        |> Board.move("e4", :white)

      assert board.pieces[:e2] == nil
      assert board.pieces[:e4].origin == :e2
    end

    test "promotion" do
      board =
        Board.new()
        |> Board.move("b4", :white)
        |> Board.move("a5", :black)
        |> Board.move("xa5", :white)
        |> Board.move("Ra6", :black)
        |> Board.move("a3", :white)
        |> Board.move("Rb6", :black)
        |> Board.move("a6", :white)
        |> Board.move("h6", :black)
        |> Board.move("a7", :white)
        |> Board.move("h5", :black)
        |> Board.move("a8=Q", :white)

      assert board.pieces[:a8] == %Piece{
               role: :queen,
               color: :white,
               origin: :b2
             }
    end
  end

  describe "FEN.to_fen/1" do
    test "can describe the initial state of a standard chess game" do
      board = Board.new()

      assert FEN.to_fen(board) == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    end

    test "can describe the state of the board after a move" do
      board = Board.new() |> Board.move("e4", :white)

      assert FEN.to_fen(board) == "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
    end
  end
end
