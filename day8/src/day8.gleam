import gleam/dict
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

fn unsafe_unwrap(res: Result(a, b)) -> a {
  case res {
    Ok(val) -> val
    _ -> panic
  }
}

fn just(inp: a, func: fn(a) -> Result(b, c)) -> b {
  func(inp) |> unsafe_unwrap
}

fn at(lst: List(a), i: Int) -> a {
  lst
  |> list.take(i + 1)
  |> list.drop(i)
  |> just(list.first)
}

fn read_input() -> List(List(String)) {
  read("input.txt")
  |> unsafe_unwrap
  |> string.split("\n")
  |> list.map(string.to_graphemes)
}

fn isalnum(c: String) -> Bool {
  c
  |> string.to_graphemes
  |> list.map(string.to_utf_codepoints)
  |> list.map(list.first)
  |> list.map(unsafe_unwrap)
  |> list.map(string.utf_codepoint_to_int)
  |> list.map(fn(i) {
    { i >= 65 && i <= 90 } || { i >= 97 && i <= 122 } || { i >= 48 && i <= 57 }
  })
  |> list.all(fn(b) { b })
}

fn in_bounds(m, n, x, y) -> Bool {
  x >= 0 && x < m && y >= 0 && y < n
}

fn get_node_map(
  grid: List(List(String)),
) -> dict.Dict(String, List(#(String, Int, Int))) {
  grid
  |> list.index_map(fn(row, i) {
    row
    |> list.index_map(fn(c, j) { #(isalnum(c), c, i, j) })
    |> list.filter(fn(t) { t.0 })
  })
  |> list.flatten
  |> list.map(fn(t) { #(t.1, t.2, t.3) })
  |> list.group(fn(t) { t.0 })
}

fn min(a: #(String, Int, Int), b: #(String, Int, Int)) {
  case a.1 < b.1 {
    True -> a
    False ->
      case a.1 == b.1 {
        True ->
          case a.2 <= b.2 {
            True -> a
            False -> b
          }
        False -> b
      }
  }
}

fn max(a: #(String, Int, Int), b: #(String, Int, Int)) {
  case a.1 > b.1 {
    True -> a
    False ->
      case a.1 == b.1 {
        True ->
          case a.2 >= b.2 {
            True -> a
            False -> b
          }
        False -> b
      }
  }
}

pub fn part1() {
  let grid = read_input()
  let m = grid |> list.length
  let n = grid |> just(list.first) |> list.length

  let node_map = get_node_map(grid)
  let antinode_map =
    node_map
    |> dict.to_list
    |> list.map(fn(t) {
      t.1
      |> list.combinations(2)
      |> list.map(fn(r) {
        let x = at(r, 0)
        let y = at(r, 1)

        let a = min(x, y)
        let b = max(x, y)

        case in_bounds(m, n, 2 * a.1 - b.1, 2 * a.2 - b.2) {
          True -> {
            case in_bounds(m, n, 2 * b.1 - a.1, 2 * b.2 - a.2) {
              True -> #(True, [
                #(2 * a.1 - b.1, 2 * a.2 - b.2),
                #(2 * b.1 - a.1, 2 * b.2 - a.2),
              ])
              False -> #(True, [#(2 * a.1 - b.1, 2 * a.2 - b.2)])
            }
          }
          False -> {
            case in_bounds(m, n, 2 * b.1 - a.1, 2 * b.2 - a.2) {
              True -> #(True, [#(2 * b.1 - a.1, 2 * b.2 - a.2)])
              False -> #(False, [#(0, 0)])
            }
          }
        }
      })
      |> list.filter_map(fn(t) {
        case t.0 {
          True -> Ok(t.1)
          False -> Error(0)
        }
      })
      |> list.flatten
    })
    |> list.flatten
    |> list.unique

  list.length(antinode_map)
}

fn part2_helper_left(
  m: Int,
  n: Int,
  a: #(Int, Int),
  b: #(Int, Int),
  acc: List(#(Int, Int)),
) -> List(#(Int, Int)) {
  case in_bounds(m, n, 2 * a.0 - b.0, 2 * a.1 - b.1) {
    True ->
      part2_helper_left(
        m,
        n,
        #(2 * a.0 - b.0, 2 * a.1 - b.1),
        #(a.0, a.1),
        list.flatten([acc, [#(2 * a.0 - b.0, 2 * a.1 - b.1)]]),
      )
    False -> acc
  }
}

fn part2_helper_right(
  m: Int,
  n: Int,
  a: #(Int, Int),
  b: #(Int, Int),
  acc: List(#(Int, Int)),
) -> List(#(Int, Int)) {
  case in_bounds(m, n, 2 * b.0 - a.0, 2 * b.1 - a.1) {
    True ->
      part2_helper_right(
        m,
        n,
        #(b.0, b.1),
        #(2 * b.0 - a.0, 2 * b.1 - a.1),
        list.flatten([acc, [#(2 * b.0 - a.0, 2 * b.1 - a.1)]]),
      )
    False -> acc
  }
}

pub fn part2() {
  let grid = read_input()
  let m = grid |> list.length
  let n = grid |> just(list.first) |> list.length

  let node_map = get_node_map(grid)
  let antinode_map =
    node_map
    |> dict.to_list
    |> list.map(fn(t) {
      t.1
      |> list.combinations(2)
      |> list.map(fn(r) {
        let x = at(r, 0)
        let y = at(r, 1)

        let a = min(x, y)
        let b = max(x, y)

        let a = #(a.1, a.2)
        let b = #(b.1, b.2)

        list.flatten([
          part2_helper_left(m, n, a, b, []),
          part2_helper_right(m, n, a, b, []),
          [a, b],
        ])
      })
      |> list.filter_map(fn(l) {
        case list.length(l) > 0 {
          True -> Ok(l)
          False -> Error(0)
        }
      })
      |> list.flatten
    })
    |> list.flatten
    |> list.unique

  list.length(antinode_map)
}

pub fn main() {
  io.debug(part1())
  io.debug(part2())
}
