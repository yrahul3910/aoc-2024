import day4.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  part1()
  |> should.equal(2406)
}

pub fn part2_test() {
  part2()
  |> should.equal(1807)
}
