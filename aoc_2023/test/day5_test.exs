defmodule TestDay5 do
  use ExUnit.Case

  test "test mapped range" do
    range = MappedRange.new("52 40 48")
    assert not MappedRange.in_source_range(range, 39)
    assert MappedRange.in_source_range(range, 40)
    assert MappedRange.in_source_range(range, 41)
    assert MappedRange.in_source_range(range, 40 + 47)
    assert not MappedRange.in_source_range(range, 40 + 48)
  end

  @test_map """
  seed-to-soil map:
  50 98 2
  52 50 48
  """

  test "test range map" do
    map = RangeMap.new(@test_map)
    assert RangeMap.get(map, 79) == 81
    assert RangeMap.get(map, 14) == 14
    assert RangeMap.get(map, 55) == 57
    assert RangeMap.get(map, 13) == 13
  end


  @test_sequential_maps """
  seed-to-soil map:
  50 98 2
  52 50 48

  soil-to-fertilizer map:
  0 15 37
  37 52 2
  39 0 15
  """

  test "test SequentialRangeMaps" do
    maps = SequentialRangeMaps.new(@test_sequential_maps)
    assert SequentialRangeMaps.get(maps, 79) == 81 # 79 -> 81 -> 81
    assert SequentialRangeMaps.get(maps, 14) == 53 # 14 -> 14 -> 53
    assert SequentialRangeMaps.get(maps, 55) == 57 # 55 -> 57 -> 57
    assert SequentialRangeMaps.get(maps, 13) == 52 # 13 -> 13 -> 52
  end

  @test_task """
  seeds: 79 14 55 13

  seed-to-soil map:
  50 98 2
  52 50 48

  soil-to-fertilizer map:
  0 15 37
  37 52 2
  39 0 15

  fertilizer-to-water map:
  49 53 8
  0 11 42
  42 0 7
  57 7 4

  water-to-light map:
  88 18 7
  18 25 70

  light-to-temperature map:
  45 77 23
  81 45 19
  68 64 13

  temperature-to-humidity map:
  0 69 1
  1 0 69

  humidity-to-location map:
  60 56 37
  56 93 4
  """
  test "test simple seed list" do
    assert Day5.closest_location(@test_task) == 35
  end

  test "test simple seed range" do
    assert Day5.closest_location_of_seed_ranges(@test_task) == 46
  end

  @actual_task File.read!("data/day5.txt")
  test "test actual task with seed list" do
    assert Day5.closest_location(@actual_task) == 525792406
  end

  @tag :pending
  test "test actual task with seed range" do
    assert Day5.closest_location_of_seed_ranges(@actual_task) == 525792406
  end
end
