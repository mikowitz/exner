defprotocol Exner.FEN do
  @moduledoc """
  Function to convert pieces and boards into FEN (Forsythe Edwards Notation)
  """

  @spec to_fen(term()) :: String.t()
  def to_fen(x)
end
