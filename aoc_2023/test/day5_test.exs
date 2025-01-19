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

  @first_map """
  seed-to-soil map:
  50 98 2
  52 50 48
  """

  test "test range map" do
    map = RangeMap.new(@first_map)
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

  @last_map """
  soil-to-fertilizer map:
  0 15 37
  37 52 2
  39 0 15
  """

  test "test SequentialRangeMaps" do
    maps = SequentialRangeMaps.new(@test_sequential_maps)
    # 79 -> 81 -> 81
    assert SequentialRangeMaps.get(maps, 79) == 81
    # 14 -> 14 -> 53
    assert SequentialRangeMaps.get(maps, 14) == 53
    # 55 -> 57 -> 57
    assert SequentialRangeMaps.get(maps, 55) == 57
    # 13 -> 13 -> 52
    assert SequentialRangeMaps.get(maps, 13) == 52
  end

  test "test reduce SequentialRangeMaps " do
    maps = SequentialRangeMaps.new(@test_sequential_maps)
    # fertilizer   0 ... 34   35 36   37 38   39 ... 53   54 55 ... 99
    # soil dest   15 ... 49   50 51 | 52 53 |  0 ... 14 | 54 55 ... 99
    # seed        15 ... 49 | 98 99 | 50 51 |  0 ... 14 | 52 53 ... 97 

    intermediate = [
      {15, 51},
      {52, 53},
      {0, 14},
      {54, 99}
    ]

    final_destination_map = [
      {15, 49},
      {98, 99},
      {50, 51},
      {0, 14},
      {52, 97}
    ]

    first_map = RangeMap.new(@first_map)
    assert RangeMap.break_into(first_map, intermediate) == final_destination_map

    last_map = RangeMap.new(@last_map)
    assert RangeMap.break_into(last_map, [{0, 99}]) == intermediate

    fdm = FinalDestinationMap.new(maps)

    assert fdm == [
             {0, {15, 49}},
             {35, {98, 99}},
             {37, {50, 51}},
             {39, {0, 14}},
             {54, {52, 52}}
           ]

    # 79 -> 81 -> 81
    assert FinalDestinationMap.get(fdm, 79) == 81
    # 14 -> 14 -> 53
    assert FinalDestinationMap.get(fdm, 14) == 53
    # 55 -> 57 -> 57
    assert FinalDestinationMap.get(fdm, 55) == 57
    # 13 -> 13 -> 52
    assert FinalDestinationMap.get(fdm, 13) == 52

    0..99
    |> Enum.each(fn i ->
      assert FinalDestinationMap.get(fdm, i) == SequentialRangeMaps.get(maps, i)
    end)

    seed_ranges = [
      # -> 0
      {11, 4},
      # -> 1
      {16, 4}
    ]

    assert FinalDestinationMap.closest_location_of_seed_ranges(fdm, seed_ranges) == 0
  end

  # 79, 80, .. 92

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
    assert Day5.closest_location(@actual_task) == 525_792_406
  end

  test "test actual task with seed range" do
    assert Day5.closest_location_of_seed_ranges(@actual_task) == 79_004_094
  end
end
