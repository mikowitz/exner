defmodule Exner.Square do
  @moduledoc """
  Helper methods for resolving file/rank coordinates on the chess board
  """

  defstruct [:rank, :file]

  # rank: 1 - 8
  # file: a - h

  def to_coords(square) do
    %{rank: r, file: f} = from_atom(square)
    [f - ?`, r - ?0]
  end

  def is_valid?(%__MODULE__{rank: rank, file: file}) when rank in ?1..?8 and file in ?a..?h,
    do: true

  def is_valid?(square) when is_atom(square) do
    square
    |> from_atom()
    |> is_valid?()
  end

  def is_valid?({f, r}) when f in 1..8 and r in 1..8, do: true

  def is_valid?(_), do: false

  def shift(square_name, {df, dr}) do
    square = from_atom(square_name)

    square = %{square | rank: square.rank + dr, file: square.file + df}

    case is_valid?(square) do
      false -> {:error, :invalid_shift, {square_name, {df, dr}}}
      true -> to_atom(square)
    end
  end

  defp from_atom(square) when is_atom(square) do
    [f, r] = Atom.to_string(square) |> to_charlist()
    %__MODULE__{rank: r, file: f}
  end

  defp to_atom(%__MODULE__{file: f, rank: r}) do
    String.to_atom(to_string([f, r]))
  end
end
