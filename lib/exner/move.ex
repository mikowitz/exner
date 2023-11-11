defmodule Exner.Move do
  defstruct [
    :color,
    :role,
    :to,
    :original,
    from: nil,
    capture: false,
    castle: nil,
    promotion: nil,
    check: nil
  ]

  alias Exner.PgnParser

  def from_pgn(move, color) do
    with {:ok, parsed_move} <- PgnParser.move(move) do
      parsed_move
      |> Map.merge(%{color: color, original: move})
      |> then(&struct(__MODULE__, &1))
    end
  end
end
