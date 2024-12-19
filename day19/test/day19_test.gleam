import day19.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  part1()
  |> should.equal(347)
}

pub fn part2_test() {
  part2()
  |> should.equal(919_219_286_602_165)
}
