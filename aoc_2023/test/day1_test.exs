defmodule TestDay1 do
  use ExUnit.Case

  @test_doc1 """
  1abc2
  pqr3stu8vwx
  a1b2c3d4e5f
  treb7uchet
  """

  @test_doc2 """
  3220
  abl9la
  d92a
  a0lfa2
  """

  @test_doc3 """
  two1nine
  eightwothree
  abcone2threexyz
  xtwone3four
  4nineeightseven2
  zoneight234
  7pqrstsixteen
  """

  @test_doc4 """
  1eightwo
  2twone
  3sevenine
  """

  @actual_doc File.read!("data/day1.txt")

  test "calibration doc 1" do
    assert Day1.sum_of_calibration_values(@test_doc1, with_alpha_num: false) == 142
    assert Day1.sum_of_calibration_values(@test_doc1, with_alpha_num: true) == 142
  end

  test "calibration doc 2" do
    result = 30 + 99 + 92 + 2
    assert Day1.sum_of_calibration_values(@test_doc2) == result
    assert Day1.sum_of_calibration_values(@test_doc2, with_alpha_num: true) == result
  end

  test "calibration doc 3" do
    assert Day1.sum_of_calibration_values(@test_doc3, with_alpha_num: true) == 281
  end

  test "calibration doc 4" do
    assert Day1.sum_of_calibration_values(@test_doc4, with_alpha_num: true) == 12 + 21 + 39
  end

  test "actual calibration doc without alphabetic numbers" do
    assert Day1.sum_of_calibration_values(@actual_doc) == 55447
  end

  test "actual calibration doc with alphabetic numbers" do
    assert Day1.sum_of_calibration_values(@actual_doc, with_alpha_num: true) == 54706
  end
end
