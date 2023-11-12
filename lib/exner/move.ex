defmodule Exner.Move do
  @moduledoc """
  Models a chess move parsed from PGN notation
  """

  alias Exner.{PgnParser, Piece, Square}

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

  @type t :: %__MODULE__{
          color: Piece.color(),
          role: Piece.role(),
          to: Square.name(),
          original: String.t(),
          from: String.t() | nil,
          capture: boolean(),
          castle: nil | :queenside | :kingside,
          promotion: nil | Piece.role(),
          check: nil | :check | :mate
        }

  @spec from_pgn(String.t(), Piece.color()) :: t()
  def from_pgn(move, color) do
    with {:ok, parsed_move} <- PgnParser.move(move) do
      parsed_move
      |> Map.merge(%{color: color, original: move})
      |> then(&struct(__MODULE__, &1))
    end
  end
end
