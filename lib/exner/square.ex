defmodule Exner.Square do
  @moduledoc """
  Helper methods for resolving file/rank coordinates on the chess board
  """

  defstruct [:rank, :file]

  @type t :: %__MODULE__{
          rank: integer(),
          file: integer()
        }

  @spec to_coords(name()) :: list(integer())
  def to_coords(square) do
    %{rank: r, file: f} = from_atom(square)
    [f - ?`, r - ?0]
  end

  @spec is_valid?(t() | name()) :: boolean()
  def is_valid?(%__MODULE__{rank: rank, file: file}) when rank in ?1..?8 and file in ?a..?h,
    do: true

  def is_valid?(square) when is_atom(square) do
    square
    |> from_atom()
    |> is_valid?()
  end

  def is_valid?(_), do: false

  @spec shift(name(), {integer(), integer()}) ::
          name() | {:error, atom(), {atom(), {integer(), integer()}}}
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

  @type name ::
          :a1
          | :b1
          | :c1
          | :d1
          | :e1
          | :f1
          | :g1
          | :h1
          | :a2
          | :b2
          | :c2
          | :d2
          | :e2
          | :f2
          | :g2
          | :h2
          | :a3
          | :b3
          | :c3
          | :d3
          | :e3
          | :f3
          | :g3
          | :h3
          | :a4
          | :b4
          | :c4
          | :d4
          | :e4
          | :f4
          | :g4
          | :h4
          | :a5
          | :b5
          | :c5
          | :d5
          | :e5
          | :f5
          | :g5
          | :h5
          | :a6
          | :b6
          | :c6
          | :d6
          | :e6
          | :f6
          | :g6
          | :h6
          | :a7
          | :b7
          | :c7
          | :d7
          | :e7
          | :f7
          | :g7
          | :h7
          | :a8
          | :b8
          | :c8
          | :d8
          | :e8
          | :f8
          | :g8
          | :h8
end
