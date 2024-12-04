import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import simplifile.{read}

fn read_input() -> List(List(String)) {
  read("input.txt")
  |> result.unwrap("")
  |> string.split("\n")
  |> list.map(string.split(_, ""))
}

fn at(arr: List(String), i: Int) -> String {
  list.take(arr, i)
  |> list.drop(i - 1)
  |> list.first
  |> result.unwrap("")
}

fn lat(arr: List(List(String)), i: Int) -> List(String) {
  list.take(arr, i)
  |> list.drop(i - 1)
  |> list.first
  |> result.unwrap([])
}

fn get(arr: List(List(String)), i: Int, j: Int) -> option.Option(String) {
  let nr = list.length(arr)
  let nc = list.length(result.unwrap(list.first(arr), [""]))

  case 1 <= i && i <= nr && 1 <= j && j <= nc {
    True -> option.Some(at(lat(arr, i), j))
    False -> option.None
  }
}

fn n_neighbors(arr: List(List(String)), i: Int, j: Int) -> Int {
  [
    [#(i, j), #(i + 1, j), #(i + 2, j), #(i + 3, j)],
    [#(i, j), #(i - 1, j), #(i - 2, j), #(i - 3, j)],
    [#(i, j), #(i, j + 1), #(i, j + 2), #(i, j + 3)],
    [#(i, j), #(i, j - 1), #(i, j - 2), #(i, j - 3)],
    [#(i, j), #(i + 1, j + 1), #(i + 2, j + 2), #(i + 3, j + 3)],
    [#(i, j), #(i - 1, j - 1), #(i - 2, j - 2), #(i - 3, j - 3)],
    [#(i, j), #(i + 1, j - 1), #(i + 2, j - 2), #(i + 3, j - 3)],
    [#(i, j), #(i - 1, j + 1), #(i - 2, j + 2), #(i - 3, j + 3)],
  ]
  |> list.map(fn(r) { list.map(r, fn(t) { get(arr, t.0, t.1) }) })
  |> list.filter(list.all(_, option.is_some(_)))
  |> list.map(list.map(_, option.unwrap(_, "")))
  |> list.map(string.join(_, ""))
  |> list.count(string.starts_with(_, "XMAS"))
}

fn part1_helper(arr: List(List(String)), i: Int, j: Int, sum: Int) -> Int {
  let nc = list.length(result.unwrap(list.first(arr), [""]))

  case i {
    1 -> {
      case j {
        1 -> sum
        b -> part1_helper(arr, i, b - 1, sum + n_neighbors(arr, 1, b))
      }
    }
    a -> {
      case j {
        1 -> part1_helper(arr, a - 1, nc, sum + n_neighbors(arr, a, 1))
        b -> part1_helper(arr, a, b - 1, sum + n_neighbors(arr, a, b))
      }
    }
  }
}

pub fn part1() -> Int {
  let arr = read_input()
  let nr = list.length(arr)
  let nc = list.length(result.unwrap(list.first(arr), [""]))

  part1_helper(arr, nr, nc, 0)
}

pub fn main() {
  io.debug(part1())
}
