defmodule Identicon do
  @moduledoc """
    This is a library for creating  identicon images out of string values
  """

  @doc """
    This is the main function for converting strings to identicons

    # Examples
      iex> Identicon.main("Banana")
      %Identicon.Image{
        color: {230, 249, 195},
        grid: [
        {230, 0},
        {230, 4},
        {170, 10},
        {162, 12},
        {170, 14},
        {122, 16},
        {122, 18},
        {24, 20},
        {244, 21},
        {74, 22},
        {244, 23},
        {24, 24}
        ],
        hex: [230, 249, 195, 71, 103, 45, 170, 229, 162, 85, 122, 225, 24, 244, 74,
        30]
      }
  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares_from_grid
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid = hex
    |> Enum.chunk(3)
    |> Enum.map(&mirror_row/1)
    |> List.flatten
    |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row([first, second | _] = row) do
    row ++ [second, first]
  end

  def filter_odd_squares_from_grid(%Identicon.Image{grid: grid} = image) do
     new_grid = Enum.filter(grid, fn({code, _}) ->
       rem(code, 2) == 0
     end)

     %Identicon.Image{image | grid: new_grid}
  end
end
