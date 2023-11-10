defmodule Exner.Piece do
  defstruct [:role, :color, origin: nil]

  alias Exner.Square

  @roles ~w(pawn knight bishop rook queen king)a
  @colors ~w(white black)a

  def place(%__MODULE__{} = piece, square) do
    case Square.is_valid?(square) do
      true -> %__MODULE__{piece | origin: square}
      false -> {:error, :invalid_square, square}
    end
  end

  def from(s) when is_bitstring(s) do
    case s |> to_charlist() |> List.first() |> from() do
      %__MODULE__{} = piece -> piece
      {:error, _, _} -> {:error, :invalid_piece_string, s}
    end
  end

  def from(?p), do: black(:pawn)
  def from(?n), do: black(:knight)
  def from(?b), do: black(:bishop)
  def from(?r), do: black(:rook)
  def from(?q), do: black(:queen)
  def from(?k), do: black(:king)
  def from(?P), do: white(:pawn)
  def from(?N), do: white(:knight)
  def from(?B), do: white(:bishop)
  def from(?R), do: white(:rook)
  def from(?Q), do: white(:queen)
  def from(?K), do: white(:king)
  def from(c), do: {:error, :invalid_piece_char, c}

  for role <- @roles do
    def unquote(role)(color) when color in @colors do
      %__MODULE__{color: color, role: unquote(role)}
    end

    def unquote(role)(color), do: {:error, :invalid_piece_color, color}
  end

  for color <- @colors do
    def unquote(color)(role) when role in @roles do
      %__MODULE__{color: unquote(color), role: role}
    end

    def unquote(color)(role), do: {:error, :invalid_piece_role, role}
  end
end
