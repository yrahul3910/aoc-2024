import day14.{part1, part2, unsafe_unwrap}
import gleam/string
import gleeunit
import gleeunit/should
import simplifile.{delete, read}

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  part1()
  |> should.equal(230_900_224)
}

pub fn part2_test() {
  case simplifile.is_file("out.txt") {
    Ok(True) -> {
      delete("out.txt")
      |> unsafe_unwrap
    }
    _ -> Nil
  }

  part2()
  read("out.txt")
  |> unsafe_unwrap
  |> string.contains("+++++++++++++++++++++++++++++++")
  |> should.be_true()

  delete("out.txt")
}
