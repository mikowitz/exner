defmodule Exner.Square do
  # rank: 1 - 8
  # file: a - h

  def is_valid?(square) do
    [f, r] = Atom.to_string(square) |> to_charlist()

    f in ?a..?h and r in ?1..?8
  end
end
