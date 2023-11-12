defmodule Exner.Piece do
  @moduledoc """
  Models a chess piece
  """

  alias Exner.{Move, Square}

  defstruct [:role, :color, origin: nil]

  @type role :: :pawn | :knight | :bishop | :rook | :queen | :king
  @type color :: :white | :black

  @type t :: %__MODULE__{
          role: role(),
          color: color(),
          origin: Square.name()
        }

  @roles ~w(pawn knight bishop rook queen king)a
  @colors ~w(white black)a

  @spec place(t(), Square.name()) :: t() | {:error, atom(), atom()}
  def place(%__MODULE__{} = piece, square) do
    case Square.is_valid?(square) do
      true -> %__MODULE__{piece | origin: square}
      false -> {:error, :invalid_square, square}
    end
  end

  @spec can_make_move?(t(), Move.t()) :: boolean()
  def can_make_move?(%__MODULE__{role: role, color: color}, %Move{role: role, color: color}),
    do: true

  def can_make_move?(_, _), do: false

  @spec from(String.t() | char()) :: t() | {:error, atom(), String.t()}
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
    @spec unquote(role)(color()) :: t()
    def unquote(role)(color) when color in @colors do
      %__MODULE__{color: color, role: unquote(role)}
    end

    def unquote(role)(color), do: {:error, :invalid_piece_color, color}
  end

  for color <- @colors do
    @spec unquote(color)(role()) :: t()
    def unquote(color)(role) when role in @roles do
      %__MODULE__{color: unquote(color), role: role}
    end

    def unquote(color)(role), do: {:error, :invalid_piece_role, role}
  end

  @spec default_starting_positions() :: keyword(t())
  def default_starting_positions, do: Enum.map(starting_pieces(), &{&1.origin, &1})

  @starting_positions [
    white: [
      pawn: [:a2, :b2, :c2, :d2, :e2, :f2, :g2, :h2],
      knight: [:b1, :g1],
      bishop: [:c1, :f1],
      rook: [:a1, :h1],
      queen: [:d1],
      king: [:e1]
    ],
    black: [
      pawn: [:a7, :b7, :c7, :d7, :e7, :f7, :g7, :h7],
      knight: [:b8, :g8],
      bishop: [:c8, :f8],
      rook: [:a8, :h8],
      queen: [:d8],
      king: [:e8]
    ]
  ]

  @spec starting_pieces() :: list(t())
  def starting_pieces do
    for {color, roles} <- @starting_positions do
      for {role, squares} <- roles do
        Enum.map(squares, fn s -> place(apply(__MODULE__, role, [color]), s) end)
      end
    end
    |> List.flatten()
  end

  defimpl Exner.FEN do
    def to_fen(%@for{role: role, color: color}) do
      color_mod(color).(role_to_fen(role))
    end

    defp color_mod(:white), do: &String.upcase/1
    defp color_mod(:black), do: &String.downcase/1

    defp role_to_fen(:pawn), do: "p"
    defp role_to_fen(:knight), do: "n"
    defp role_to_fen(:bishop), do: "b"
    defp role_to_fen(:rook), do: "r"
    defp role_to_fen(:queen), do: "q"
    defp role_to_fen(:king), do: "k"
  end
end
