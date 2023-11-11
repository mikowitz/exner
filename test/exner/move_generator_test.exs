defmodule Exner.MoveGeneratorTest do
  use ExUnit.Case, async: true

  alias Exner.{Board, Move, MoveGenerator}

  describe "for(pawn)" do
    test "opening move" do
      board = Board.new()

      move = Move.from_pgn("e4", :white)

      assert MoveGenerator.for(board, move) == {:e2, :e4}
    end

    test "after opening" do
      board = Board.new() |> Board.move("e4", :white)

      move = Move.from_pgn("e5", :black)

      assert MoveGenerator.for(board, move) == {:e7, :e5}
    end

    test "capturing" do
      board = Board.new() |> Board.move("e4", :white) |> Board.move("d5", :black)

      move = Move.from_pgn("xd5", :white)

      assert MoveGenerator.for(board, move) == {:e4, :d5}
    end

    test "black capturing" do
      board =
        Board.new()
        |> Board.move("e4", :white)
        |> Board.move("d5", :black)
        |> Board.move("a3", :white)

      move = Move.from_pgn("xe4", :black)

      assert MoveGenerator.for(board, move) == {:d5, :e4}
    end

    test "multiple possible captures" do
      board =
        Board.new()
        |> Board.move("d4", :white)
        |> Board.move("e5", :black)
        |> Board.move("f4", :white)
        |> Board.move("Na6", :black)

      move = Move.from_pgn("dxe5", :white)
      assert MoveGenerator.for(board, move) == {:d4, :e5}

      move = Move.from_pgn("fxe5", :white)
      assert MoveGenerator.for(board, move) == {:f4, :e5}
    end
  end

  describe "for(knight)" do
    test "opening position" do
      board = Board.new()

      move = Move.from_pgn("Nc3", :white)

      assert MoveGenerator.for(board, move) == {:b1, :c3}
    end

    test "takes into account a `from` key when both could move to the same square" do
      board =
        Board.new()
        |> Board.move("d4", :white)
        |> Board.move("d6", :black)
        |> Board.move("Nf3", :white)
        |> Board.move("e6", :black)

      move = Move.from_pgn("Nbd2", :white)

      assert MoveGenerator.for(board, move) == {:b1, :d2}
    end
  end

  describe "for(bishop)" do
    test "has no moves at the opening" do
      board = Board.new()

      move = Move.from_pgn("Be3", :white)

      assert MoveGenerator.for(board, move) == nil
    end

    test "moves can be opened up" do
      board =
        Board.new()
        |> Board.move("d4", :white)
        |> Board.move("d5", :black)

      move = Move.from_pgn("Be3", :white)

      assert MoveGenerator.for(board, move) == {:c1, :e3}
    end

    test "account for all directions" do
      board =
        Board.new()
        |> Board.move("b4", :white)
        |> Board.move("d5", :black)

      move = Move.from_pgn("Ba3", :white)

      assert MoveGenerator.for(board, move) == {:c1, :a3}
    end

    test "capture" do
      board =
        Board.new()
        |> Board.move("d4", :white)
        |> Board.move("g5", :black)

      move = Move.from_pgn("Bxg5", :white)

      assert MoveGenerator.for(board, move) == {:c1, :g5}
    end
  end

  describe "for(rook)" do
    test "no moves at the beginning" do
      board = Board.new()

      move = Move.from_pgn("Rh5", :white)

      assert MoveGenerator.for(board, move) == nil
    end

    test "after an opening is given" do
      board =
        Board.new()
        |> Board.move("h4", :white)
        |> Board.move("g5", :black)
        |> Board.move("xg5", :white)
        |> Board.move("d6", :black)

      move = Move.from_pgn("Rh5", :white)

      assert MoveGenerator.for(board, move) == {:h1, :h5}
    end

    test "when multiple moves are possible" do
      board =
        Board.new()
        |> Board.move("a4", :white)
        |> Board.move("a6", :black)
        |> Board.move("h4", :white)
        |> Board.move("b6", :black)
        |> Board.move("Ra3", :white)
        |> Board.move("c6", :black)
        |> Board.move("Rhh3", :white)
        |> Board.move("d6", :black)

      move = Move.from_pgn("Rad3", :white)
      assert MoveGenerator.for(board, move) == {:a3, :d3}
      move = Move.from_pgn("Rhd3", :white)
      assert MoveGenerator.for(board, move) == {:h3, :d3}
    end
  end

  describe "for(queen)" do
    test "no moves at the beginning" do
      board = Board.new()

      move = Move.from_pgn("Qd4", :white)

      assert MoveGenerator.for(board, move) == nil
    end

    test "after an opening is given" do
      board =
        Board.new()
        |> Board.move("d4", :white)
        |> Board.move("e5", :black)
        |> Board.move("xe5", :white)
        |> Board.move("d6", :black)

      move = Move.from_pgn("Qxd6", :white)

      assert MoveGenerator.for(board, move) == {:d1, :d6}
    end

    test "after a diagonal opening is given" do
      board =
        Board.new()
        |> Board.move("c4", :white)
        |> Board.move("e5", :black)

      move = Move.from_pgn("Qa4", :white)

      assert MoveGenerator.for(board, move) == {:d1, :a4}
    end
  end

  describe "for(king)" do
    test "no moves at the beginning" do
      board = Board.new()

      move = Move.from_pgn("Kd1", :white)

      assert MoveGenerator.for(board, move) == nil
    end

    test "after an opening is given" do
      board =
        Board.new()
        |> Board.move("d4", :white)
        |> Board.move("e5", :black)
        |> Board.move("xe5", :white)
        |> Board.move("d6", :black)
        |> Board.move("Qxd6", :white)
        |> Board.move("a6", :black)

      move = Move.from_pgn("Kd1", :white)

      assert MoveGenerator.for(board, move) == {:e1, :d1}
    end

    test "after a diagonal opening is given" do
      board =
        Board.new()
        |> Board.move("c4", :white)
        |> Board.move("e5", :black)

      move = Move.from_pgn("Qa4", :white)

      assert MoveGenerator.for(board, move) == {:d1, :a4}
    end
  end

  describe "castling" do
    test "white kingside" do
      board = Board.new()
      move = Move.from_pgn("O-O", :white)

      assert MoveGenerator.for(board, move) == [{:e1, :g1}, {:h1, :f1}]
    end

    test "white queenside" do
      board = Board.new()
      move = Move.from_pgn("O-O-O", :white)

      assert MoveGenerator.for(board, move) == [{:e1, :c1}, {:a1, :d1}]
    end

    test "black kingside" do
      board = Board.new() |> Board.move("e3", :white)
      move = Move.from_pgn("O-O", :black)

      assert MoveGenerator.for(board, move) == [{:e8, :g8}, {:h8, :f8}]
    end

    test "black queenside" do
      board = Board.new() |> Board.move("e3", :white)
      move = Move.from_pgn("O-O-O", :black)

      assert MoveGenerator.for(board, move) == [{:e8, :c8}, {:a8, :d8}]
    end
  end
end
