defmodule Exner.MoveGenerator do
  alias Exner.{Move, Piece, Square}

  @knight_moves [{1, 2}, {2, 1}, {2, -1}, {1, -2}, {-1, -2}, {-2, -1}, {-2, 1}, {-1, 2}]

  @king_moves for x <- -1..1, y <- -1..1, x != 0 || y != 0, do: {x, y}

  @bishop_slides [
    for(i <- 1..7, do: {i, i}),
    for(i <- 1..7, do: {-i, -i}),
    for(i <- 1..7, do: {i, -i}),
    for(i <- 1..7, do: {-i, i})
  ]

  @rook_slides [
    for(i <- 1..7, do: {i, 0}),
    for(i <- 1..7, do: {-i, 0}),
    for(i <- 1..7, do: {0, -i}),
    for(i <- 1..7, do: {0, i})
  ]

  @queen_slides @bishop_slides ++ @rook_slides

  @castling_positions [
    kingside: [
      white: [:e1, :h1],
      black: [:e8, :h8]
    ],
    queenside: [
      white: [:e1, :a1],
      black: [:e8, :a8]
    ]
  ]

  @castling_moves [
    kingside: [{2, 0}, {-2, 0}],
    queenside: [{-2, 0}, {3, 0}]
  ]

  def for(_board, %Move{castle: castle, color: color}) when not is_nil(castle) do
    [king, rook] = @castling_positions[castle][color]

    [king_move, rook_move] = @castling_moves[castle]

    [
      {king, Square.shift(king, king_move)},
      {rook, Square.shift(rook, rook_move)}
    ]
  end

  def for(board, move) do
    from_and_mover =
      board.pieces
      |> Enum.filter(fn {_square, piece} -> Piece.can_make_move?(piece, move) end)
      |> Enum.filter(fn {square, piece} ->
        move.to in potential_destinations(piece, square, board, move)
      end)
      |> Enum.filter(fn {square, _piece} ->
        case move.from do
          nil -> true
          from -> String.contains?(to_string(square), from)
        end
      end)
      |> List.first()

    case from_and_mover do
      nil -> nil
      {from, _} -> {from, move.to}
    end
  end

  defp potential_destinations(
         %{role: :pawn, color: color} = _piece,
         current_location,
         _board,
         %{capture: true} = _move
       ) do
    rank_delta = color_polarity(color)
    shift(current_location, [{1, rank_delta}, {-1, rank_delta}])
  end

  defp potential_destinations(
         %{role: :pawn, color: color, origin: origin} = piece,
         current_location,
         board,
         move
       ) do
    rank_polarity = color_polarity(color)

    case current_location == origin do
      true -> shift(current_location, [{0, 1 * rank_polarity}, {0, 2 * rank_polarity}])
      false -> shift(current_location, [{0, 1 * rank_polarity}])
    end
    |> Enum.filter(&is_atom/1)
    |> Enum.map(&check_for_occupancy(&1, piece, board, move))
    |> Enum.reject(&is_nil/1)
  end

  defp potential_destinations(
         %{role: :knight} = piece,
         current_location,
         board,
         move
       ) do
    shift(current_location, @knight_moves)
    |> Enum.filter(&is_atom/1)
    |> Enum.map(&check_for_occupancy(&1, piece, board, move))
    |> Enum.reject(&is_nil/1)
  end

  defp potential_destinations(
         %{role: :bishop} = piece,
         current_location,
         board,
         move
       ) do
    @bishop_slides
    |> Enum.map(&find_sliding_moves(&1, current_location, piece, board, move))
    |> List.flatten()
  end

  defp potential_destinations(
         %{role: :rook} = piece,
         current_location,
         board,
         move
       ) do
    @rook_slides
    |> Enum.map(&find_sliding_moves(&1, current_location, piece, board, move))
    |> List.flatten()
  end

  defp potential_destinations(
         %{role: :queen} = piece,
         current_location,
         board,
         move
       ) do
    @queen_slides
    |> Enum.map(&find_sliding_moves(&1, current_location, piece, board, move))
    |> List.flatten()
  end

  defp potential_destinations(
         %{role: :king} = piece,
         current_location,
         board,
         move
       ) do
    shift(current_location, @king_moves)
    |> Enum.filter(&is_atom/1)
    |> Enum.map(&check_for_occupancy(&1, piece, board, move))
    |> Enum.reject(&is_nil/1)
  end

  defp check_for_occupancy(square, piece, board, move) do
    case board.pieces[square] do
      nil ->
        square

      %Piece{} = encountered_piece ->
        if encountered_piece.color == piece.color do
          nil
        else
          if move.capture do
            square
          else
            nil
          end
        end
    end
  end

  defp find_sliding_moves(deltas, current_location, piece, board, move) do
    Enum.reduce_while(deltas, [], fn d, acc ->
      destination = Square.shift(current_location, d)

      case Square.is_valid?(destination) do
        false ->
          {:halt, acc}

        true ->
          case board.pieces[destination] do
            nil ->
              {:cont, [destination | acc]}

            %Piece{} = encountered_piece ->
              if encountered_piece.color == piece.color do
                {:halt, acc}
              else
                if move.capture do
                  {:halt, [destination | acc]}
                else
                  {:halt, acc}
                end
              end
          end
      end
    end)
  end

  defp color_polarity(:white), do: 1
  defp color_polarity(:black), do: -1

  defp shift(square, shifts) do
    Enum.map(shifts, &Square.shift(square, &1))
  end
end
