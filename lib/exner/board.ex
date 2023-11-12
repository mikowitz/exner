defmodule Exner.Board do
  @moduledoc """
  Models a chessboard + additional context needed to play a game
  """

  alias Exner.{Move, MoveGenerator, Piece, Square}

  defstruct [
    :pieces,
    side_to_move: :white,
    # KQkq
    castling_rights: 15,
    en_passant_square: nil,
    halfmove_clock: 0,
    fullmove_clock: 1
  ]

  @type t :: %__MODULE__{
          pieces: keyword(Piece.t()),
          side_to_move: Piece.color(),
          castling_rights: 0..15,
          en_passant_square: Square.name() | nil,
          halfmove_clock: integer(),
          fullmove_clock: pos_integer()
        }

  @spec new(keyword(Piece.t()) | nil) :: t()
  def new(pieces \\ Piece.default_starting_positions()) do
    %__MODULE__{pieces: pieces}
  end

  @spec move(t(), Move.t(), Piece.color()) :: t() | {:error, atom, Piece.color()}

  def move(%__MODULE__{side_to_move: side_to_move}, _move, color)
      when side_to_move != color do
    {:error, :wrong_side_to_move, color}
  end

  def move(%__MODULE__{} = board, %Move{castle: nil} = move, color) do
    {from, to} = MoveGenerator.for(board, move)

    mover = board.pieces[from]

    mover =
      case move.promotion do
        nil -> mover
        role -> %{mover | role: role}
      end

    pieces =
      board.pieces
      |> Keyword.delete(from)
      |> Keyword.put(to, mover)

    %__MODULE__{board | pieces: pieces}
    |> toggle_side_to_move()
    |> check_for_en_passant(move.role, color, from, to)
  end

  def move(%__MODULE__{} = board, %Move{castle: castle} = move, _color)
      when castle in [:kingside, :queenside] do
    [{king_from, king_to}, {rook_from, rook_to}] = MoveGenerator.for(board, move)

    king = board.pieces[king_from]
    rook = board.pieces[rook_from]

    pieces =
      board.pieces
      |> Keyword.delete(king_from)
      |> Keyword.put(king_to, king)
      |> Keyword.delete(rook_from)
      |> Keyword.put(rook_to, rook)

    %__MODULE__{board | pieces: pieces}
    |> toggle_side_to_move()
  end

  def move(%__MODULE__{} = board, move, color) do
    with %Move{} = move <- Move.from_pgn(move, color) do
      move(board, move, color)
    end
  end

  @next_color [white: :black, black: :white]

  defp toggle_side_to_move(%__MODULE__{side_to_move: color} = board),
    do: %__MODULE__{board | side_to_move: @next_color[color]}

  @en_passant_coords [white: {0, -1}, black: {0, 1}]

  defp check_for_en_passant(board, :pawn, color, from, to) do
    [ff, fr] = Square.to_coords(from)
    [tf, tr] = Square.to_coords(to)

    case abs(fr - tr) == 2 && abs(ff - tf) == 0 do
      false -> board
      true -> %__MODULE__{board | en_passant_square: Square.shift(to, @en_passant_coords[color])}
    end
  end

  defp check_for_en_passant(board, _, _, _, _), do: board
end
