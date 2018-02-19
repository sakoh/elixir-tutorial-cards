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
        hex: [230, 249, 195, 71, 103, 45, 170, 229, 162, 85, 122, 225, 24, 244, 74, 30],
        pixel_map: [
          {{0, 0}, {50, 50}},
          {{200, 0}, {250, 50}},
          {{0, 100}, {50, 150}},
          {{100, 100}, {150, 150}},
          {{200, 100}, {250, 150}},
          {{50, 150}, {100, 200}},
          {{150, 150}, {200, 200}},
          {{0, 200}, {50, 250}},
          {{50, 200}, {100, 250}},
          {{100, 200}, {150, 250}},
          {{150, 200}, {200, 250}},
          {{200, 200}, {250, 250}}
        ]
      }
  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares_from_grid
    |> build_pixel_map
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

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}
      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end
end
