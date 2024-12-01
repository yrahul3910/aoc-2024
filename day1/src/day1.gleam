import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

fn read_input() -> #(List(Int), List(Int)) {
  read("input.txt")
  |> result.unwrap("")
  |> string.split("\n")
  |> list.map(string.split(_, "   "))
  |> list.map(list.map(_, int.parse))
  |> list.map(list.map(_, result.unwrap(_, 0)))
  |> list.map(fn(x) {
    #(result.unwrap(list.first(x), 0), result.unwrap(list.last(x), 0))
  })
  |> list.unzip
}

pub fn part1() -> Int {
  read_input()
  |> fn(x) {
    #(list.sort(x.0, by: int.compare), list.sort(x.1, by: int.compare))
  }
  |> fn(x) { list.zip(x.0, x.1) }
  |> list.map(fn(x) { x.1 - x.0 })
  |> list.map(int.absolute_value)
  |> int.sum
}

pub fn part2() {
  let #(a, b) = read_input()

  a
  |> list.map(fn(x) { x * list.count(b, fn(y) { y == x }) })
  |> int.sum
}

pub fn main() {
  io.println("Part 1: " <> int.to_string(part1()))
  io.println("Part 2: " <> int.to_string(part2()))
}
