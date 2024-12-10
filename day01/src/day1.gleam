import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

fn get(val: Result(Int, Nil)) -> Int {
  result.unwrap(val, 0)
}

fn read_input() -> #(List(Int), List(Int)) {
  read("input.txt")
  |> result.unwrap("")
  |> string.split("\n")
  |> list.map(string.split(_, "   "))
  |> list.map(list.map(_, int.parse))
  |> list.map(list.map(_, get))
  |> list.map(fn(x) { #(get(list.first(x)), get(list.last(x))) })
  |> list.unzip
}

pub fn part1() -> Int {
  read_input()
  |> fn(x) {
    #(list.sort(x.0, by: int.compare), list.sort(x.1, by: int.compare))
  }
  |> fn(x) { list.zip(x.0, x.1) }
  |> list.map(fn(x) { x.1 - x.0 })
  |> list.reduce(fn(acc, x) { acc + int.absolute_value(x) })
  |> get
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
