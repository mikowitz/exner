defmodule Exner.Square do
  # rank: 1 - 8
  # file: a - h

  def is_valid?(square) when is_atom(square) do
    [f, r] = square_to_fr(square)
    f in ?a..?h and r in ?1..?8
  end

  def is_valid?(_), do: false

  def shift(square, {df, dr}) do
    [f, r] = square_to_coords(square)

    [f, r] = [f + df, r + dr]

    case f in 1..8 and r in 1..8 do
      false -> {:error, :invalid_shift, {square, {df, dr}}}
      true -> coords_to_square(f, r)
    end
  end

  def square_to_fr(square) do
    Atom.to_string(square) |> to_charlist()
  end

  def square_to_coords(square) do
    [f, r] = square_to_fr(square)

    [f - ?`, r - ?0]
  end

  defp coords_to_square(f, r) do
    [f + ?`, r + ?0]
    |> to_string()
    |> String.to_atom()
  end
end
