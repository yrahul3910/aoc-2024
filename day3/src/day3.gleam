import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string
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

fn basic_match(str: String) -> Int {
  let val =
    regexp.compile("mul\\((\\d+),(\\d+)\\)", with: regexp.Options(False, False))

  case val {
    Ok(rgx) -> str |> get_all_matches(rgx, _) |> int.sum
    Error(_) -> 0
  }
}

pub fn part1() -> Int {
  basic_match(read_input())
}

fn part2_helper(str: String, acc: Int) -> Int {
  case str {
    "" -> acc
    val -> {
      let parts =
        string.split_once(val, "don't()")
        |> result.unwrap(#("", ""))
        |> fn(parts) {
          #(
            parts.0,
            result.unwrap(string.split_once(parts.1, "do()"), #("", "")).1,
          )
        }

      part2_helper(parts.1, acc + basic_match(parts.0))
    }
  }
}

pub fn part2() -> Int {
  read_input()
  |> part2_helper(0)
}

pub fn main() {
  let p1 = part1()
  let p2 = part2()

  io.debug("Part 1: " <> int.to_string(p1))
  io.debug("Part 2: " <> int.to_string(p2))
}
