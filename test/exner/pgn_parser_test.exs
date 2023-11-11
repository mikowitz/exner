defmodule Exner.PgnParserTest do
  use ExUnit.Case, async: true

  alias Exner.Move
  alias Exner.PgnParser

  describe "file/1" do
    test "parses a pgn file" do
      parsed_file = PgnParser.file("priv/spassky_fischer_1972.pgn")

      assert map_size(parsed_file.annotations) == 12

      assert length(parsed_file.moves) == 74

      assert Enum.at(parsed_file.moves, 0) == [
               Move.from_pgn("e4", :white),
               Move.from_pgn("Nf6", :black)
             ]
    end
  end

  describe "move/1" do
    test "parses a queenside castle" do
      assert PgnParser.move("O-O-O") == {:ok, %{castle: :queenside}}
    end

    test "parses a kingside castle" do
      assert PgnParser.move("O-O") == {:ok, %{castle: :kingside}}
    end

    test "parses a simple pawn move" do
      assert PgnParser.move("e4") == {:ok, %{role: :pawn, to: :e4, capture: false}}
    end

    test "parses a simple capture move" do
      assert PgnParser.move("Bxd3") == {:ok, %{role: :bishop, to: :d3, capture: true}}
    end

    test "parses a pawn capture" do
      assert PgnParser.move("hxg5") == {:ok, %{role: :pawn, to: :g5, capture: true, from: "h"}}
    end

    test "parses a move with a from" do
      assert PgnParser.move("Nbxa4") == {:ok, %{role: :knight, to: :a4, capture: true, from: "b"}}
    end

    test "parses a check" do
      assert PgnParser.move("Rd1+") ==
               {:ok, %{role: :rook, to: :d1, capture: false, check: :check}}
    end

    test "parses a checkmate" do
      assert PgnParser.move("Qd7#") ==
               {:ok, %{role: :queen, to: :d7, capture: false, check: :mate}}
    end

    test "parses a promotion" do
      assert PgnParser.move("h1=Q") ==
               {:ok, %{role: :pawn, to: :h1, capture: false, promotion: :queen}}
    end
  end
end
