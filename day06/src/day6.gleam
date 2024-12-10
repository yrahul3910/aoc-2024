import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

fn read_input() -> List(List(String)) {
  read("input.txt")
  |> result.unwrap("")
  |> string.split("\n")
  |> list.map(string.split(_, ""))
}

fn sym_to_dir(d: String) -> #(Int, Int) {
  case d {
    "^" -> #(0, -1)
    ">" -> #(1, 0)
    "v" -> #(0, 1)
    "<" -> #(-1, 0)
    _ -> #(0, 0)
  }
}

fn turn_right(d: String) -> String {
  case d {
    "^" -> ">"
    ">" -> "v"
    "v" -> "<"
    "<" -> "^"
    _ -> d
  }
}

fn at(arr: List(a), i: Int) -> Result(a, Nil) {
  list.take(arr, i + 1)
  |> list.drop(i)
  |> list.first
}

fn get(arr: List(List(String)), i: Int, j: Int) -> String {
  let nr = list.length(arr)
  let nc = list.length(result.unwrap(list.first(arr), [""]))

  case 0 <= i && i < nr && 0 <= j && j < nc {
    True -> {
      result.unwrap(at(result.unwrap(at(arr, i), [""]), j), "")
    }
    False -> "o"
  }
}

fn walk(
  grid: List(List(String)),
  guard: #(Int, Int),
  dir: String,
  path: List(#(Int, Int)),
) {
  let in_front =
    get(grid, guard.0 + sym_to_dir(dir).1, guard.1 + sym_to_dir(dir).0)

  let new_dir = case in_front {
    "#" -> turn_right(dir)
    _ -> dir
  }
  let new_guard = #(
    guard.0 + sym_to_dir(new_dir).1,
    guard.1 + sym_to_dir(new_dir).0,
  )

  case in_front {
    "o" -> path
    "#" -> walk(grid, new_guard, new_dir, list.flatten([path, [new_guard]]))
    _ -> walk(grid, new_guard, new_dir, list.flatten([path, [new_guard]]))
  }
}

fn get_guard(grid: List(List(String))) -> #(#(Int, Int), String) {
  let dirs = ["^", "<", "v", ">"]

  let row =
    grid
    |> list.index_map(fn(row, i) { #(row, i) })
    |> list.filter(fn(t) {
      t.0
      |> list.any(list.contains(dirs, _))
    })
    |> list.first
    |> result.unwrap(#([], -1))

  let i = row.1
  let row = row.0

  let col =
    row
    |> list.index_map(fn(c, i) { #(c, i) })
    |> list.filter(fn(t) { list.contains(dirs, t.0) })
    |> list.first
    |> result.unwrap(#("", -1))

  let j = col.1
  let cell = col.0

  #(#(i, j), cell)
}

pub fn part1() {
  let grid = read_input()
  let guard_pos = get_guard(grid)

  walk(grid, guard_pos.0, guard_pos.1, [guard_pos.0])
  |> list.unique
  |> list.length
}

pub fn main() {
  io.debug(part1())
}
