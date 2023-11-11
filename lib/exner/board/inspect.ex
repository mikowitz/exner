defimpl Inspect, for: Exner.Board do
  def inspect(%@for{pieces: pieces}, _opts) do
    for r <- 8..1 do
      inspect_rank(r, pieces)
    end
    |> Enum.join("\n")
  end

  defp inspect_rank(rank, pieces) do
    for f <- ?a..?h do
      case pieces[String.to_atom(to_string([f, rank + ?0]))] do
        nil -> "_"
        piece -> Exner.FEN.to_fen(piece)
      end
    end
    |> Enum.join(" ")
  end
end
