defmodule Exner.PgnParser do
  @moduledoc """
  Functions to parse files and moves in PGN notation
  """

  alias Exner.Move

  @move_regex ~r/
    (?<role>[NBRQK])?
    (?<from>[a-h]?[1-8]?)
    (?<capture>x)?
    (?<to>[a-h][1-8])
    (?<check>[+#])?
    (?<promotion>=[NBRQK])?
  /x

  @annotation_regex ~r/
    \[
    (\w+)
    \s+
    \"([^"]+)\"
    \]
  /x

  @round_regex ~r/\d+\.\s+(\S+)\s+(\S+)/

  def file(filename) do
    text = File.read!(filename)

    annotations =
      Regex.scan(@annotation_regex, text)
      |> Enum.map(fn [_, key, value] -> {key, value} end)
      |> Enum.into(%{})

    rounds =
      Regex.scan(@round_regex, text)
      |> Enum.map(fn [_, white, black] ->
        [Move.from_pgn(white, :white), Move.from_pgn(black, :black)] |> Enum.reject(&is_nil/1)
      end)

    %{
      annotations: annotations,
      moves: rounds
    }
  end

  def move("O-O"), do: {:ok, %{castle: :kingside}}
  def move("O-O-O"), do: {:ok, %{castle: :queenside}}

  def move("1-0"), do: nil
  def move("0-1"), do: nil
  def move("1/2-1/2"), do: nil

  def move(move) do
    parsed = Regex.named_captures(@move_regex, move)

    {:ok,
     %{
       role: parse_role(parsed["role"]),
       to: String.to_atom(parsed["to"]),
       capture: parsed["capture"] == "x",
       from: parse_from(parsed["from"]),
       check: parse_check(parsed["check"]),
       promotion: parse_promotion(parsed["promotion"])
     }
     |> Map.reject(fn {_k, v} -> is_nil(v) end)}
  end

  defp parse_role("K"), do: :king
  defp parse_role("Q"), do: :queen
  defp parse_role("R"), do: :rook
  defp parse_role("B"), do: :bishop
  defp parse_role("N"), do: :knight
  defp parse_role(_), do: :pawn

  defp parse_from(""), do: nil
  defp parse_from(from), do: from

  defp parse_check("+"), do: :check
  defp parse_check("#"), do: :mate
  defp parse_check(""), do: nil

  defp parse_promotion(""), do: nil
  defp parse_promotion("=" <> role), do: parse_role(role)
end
