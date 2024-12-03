import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import simplifile.{read}

fn read_input() -> String {
  read("input.txt")
  |> result.unwrap("")
}

fn match_to_ints(match: regexp.Match) -> List(Int) {
  match.submatches
  |> list.map(option.unwrap(_, "0"))
  |> list.map(int.parse)
  |> list.map(result.unwrap(_, -1))
}

fn get_all_matches(rgx: regexp.Regexp, input: String) -> List(Int) {
  regexp.scan(rgx, input)
  |> list.map(match_to_ints)
  |> list.map(list.reduce(_, fn(acc, cur) { acc * cur }))
  |> list.map(result.unwrap(_, -2))
}

pub fn part1() -> Int {
  let val =
    regexp.compile("mul\\((\\d+),(\\d+)\\)", with: regexp.Options(False, False))

  case val {
    Ok(rgx) -> read_input() |> get_all_matches(rgx, _) |> int.sum
    Error(_) -> 0
  }
}

pub fn part2() -> Int {
  let val =
    regexp.compile(
      "(?:^|do\\(\\)).*mul\\((\\d+),(\\d+)\\)(?:don't\\(\\)|$)",
      with: regexp.Options(False, False),
    )

  case val {
    Ok(rgx) -> read_input() |> get_all_matches(rgx, _) |> int.sum
    Error(_) -> 0
  }
}

pub fn main() {
  let p1 = part1()
  io.debug("Part 1: " <> int.to_string(p1))
}
