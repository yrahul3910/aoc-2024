import day13.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  part1()
  |> should.equal(29_522)
}

pub fn part2_test() {
  part2()
  |> should.equal(101_214_869_433_312)
}
