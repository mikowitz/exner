defimpl Exner.FEN, for: Exner.Board do
  def to_fen(%@for{} = board) do
    [
      pieces(board.pieces),
      side(board.side_to_move),
      castling(board.castling_rights),
      en_passant(board.en_passant_square),
      clocks(board.halfmove_clock, board.fullmove_clock)
    ]
    |> Enum.join(" ")
  end

  defp pieces(pieces) do
    for r <- ?8..?1 do
      for f <- ?a..?h do
        key = String.to_atom(to_string([f, r]))
        pieces[key]
      end
      |> collapse_rank_fen()
    end
    |> Enum.join("/")
  end

  defp collapse_rank_fen(squares) do
    squares
    |> Enum.chunk_by(&is_nil/1)
    |> Enum.map(fn
      [nil | _] = l -> to_string(length(l))
      l -> l |> Enum.map(&@protocol.to_fen/1) |> Enum.join("")
    end)
    |> Enum.join("")
  end

  defp side(:white), do: "w"
  defp side(:black), do: "b"

  defp castling(rights) do
    [K: 8, Q: 4, k: 2, q: 1]
    |> Enum.filter(fn {_key, bit} -> Bitwise.band(bit, rights) == bit end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&to_string/1)
    |> Enum.join("")
  end

  defp en_passant(nil), do: "-"
  defp en_passant(square), do: to_string(square)

  defp clocks(halfmoves, fullmoves), do: [halfmoves, fullmoves] |> Enum.join(" ")
end
