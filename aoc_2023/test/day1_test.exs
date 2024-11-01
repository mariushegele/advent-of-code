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
             foo
             bar
             """

  @actual_doc File.read!("data/day1.txt")

  test "calibration doc 1" do
    assert Day1.sum_of_calibration_values(@test_doc1) == 142
  end

  test "calibration doc 2" do
    assert Day1.sum_of_calibration_values(@test_doc2) == 30 + 99 + 92 + 2
  end

  test "actual calibration doc" do
    assert Day1.sum_of_calibration_values(@actual_doc) == 55447
  end

  @tag :pending
  test "erroneous calibration doc" do
    Day1.sum_of_calibration_values(@test_doc3)
  end
end
