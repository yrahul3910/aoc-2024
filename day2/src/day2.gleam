import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

fn get(val: Result(Int, Nil)) -> Int {
  result.unwrap(val, 0)
}

fn read_input() -> List(List(Int)) {
  read("input.txt")
  |> result.unwrap("")
  |> string.split("\n")
  |> list.map(string.split(_, " "))
  |> list.map(list.map(_, int.parse))
  |> list.map(list.map(_, get))
}

fn safe_report(report: List(Int)) -> Bool {
  {
    { list.sort(report, by: int.compare) == report }
    || { list.reverse(list.sort(report, by: int.compare)) == report }
  }
  && {
    list.zip(list.take(report, list.length(report) - 1), list.drop(report, 1))
    |> list.map(fn(t) { int.absolute_value(t.1 - t.0) })
    |> list.all(fn(x) { x >= 1 && x <= 3 })
  }
}

fn extended_safe_report(report: List(Int)) -> Bool {
  safe_report(report)
  || {
    list.any(
      list.index_map(report, fn(_, i) {
        list.flatten([list.take(report, i), list.drop(report, i + 1)])
      }),
      safe_report,
    )
  }
}

pub fn part1() -> Int {
  read_input()
  |> list.map(safe_report)
  |> list.map(bool.to_int)
  |> int.sum
}

pub fn part2() -> Int {
  read_input()
  |> list.map(extended_safe_report)
  |> list.map(bool.to_int)
  |> int.sum
}

pub fn main() {
  let p1 = part1()
  let p2 = part2()

  io.println("Part 1: " <> int.to_string(p1))
  io.println("Part 2: " <> int.to_string(p2))
}
