import gleam/deque
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

fn read_input() -> List(#(Int, Int)) {
  read("input.txt")
  |> unsafe_unwrap
  |> string.split("\n")
  |> list.map(string.split(_, ","))
  |> list.map(list.map(_, int.parse))
  |> list.map(list.map(_, unsafe_unwrap))
  |> list.map(fn(x) { #(at(x, 0), at(x, 1)) })
}

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

fn set(grid: List(List(a)), x: Int, y: Int, val: a) -> List(List(a)) {
  grid
  |> list.index_map(fn(row, i) {
    case i == x {
      False -> row
      True ->
        row
        |> list.index_map(fn(cell, j) {
          case j == y {
            True -> val
            False -> cell
          }
        })
    }
  })
}

fn mkgrid() {
  list.repeat(list.repeat(0, 71), 71)
}

fn bfs_helper(
  coords: List(#(Int, Int)),
  grid: List(List(Int)),
  q: deque.Deque(#(Int, Int, Int)),
) {
  case deque.is_empty(q) {
    True -> -1
    False -> {
      let #(#(x, y, d), q) = q |> just(deque.pop_front)

      case x, y {
        70, 70 -> d
        _, _ -> {
          let #(q1, grid) =
            [#(0, 1), #(1, 0), #(0, -1), #(-1, 0)]
            |> list.map(fn(t) { #(x + t.0, y + t.1, d + 1) })
            |> list.filter(fn(t) {
              t.0 >= 0
              && t.1 >= 0
              && t.0 <= 70
              && t.1 <= 70
              && at(at(grid, t.0), t.1) == 0
              && !list.contains(coords, #(t.0, t.1))
            })
            |> list.fold(#([], grid), fn(acc, t) {
              #([t, ..acc.0], set(acc.1, t.0, t.1, 1))
            })

          let q = list.flatten([deque.to_list(q), q1]) |> deque.from_list

          bfs_helper(coords, grid, q)
        }
      }
    }
  }
}

fn bfs(coords: List(#(Int, Int))) {
  let grid = set(mkgrid(), 0, 0, 1)
  let q = deque.from_list([#(0, 0, 0)])

  bfs_helper(coords, grid, q)
}

pub fn part1() {
  let coords = read_input()
  bfs(coords |> list.take(1024))
}

fn part2_helper(coords: List(#(Int, Int))) {
  let len = coords |> list.length
  case bfs(coords) {
    -1 -> part2_helper(coords |> list.take(len - 1))
    _d -> len
  }
}

pub fn part2() {
  let coords = read_input()
  let idx = part2_helper(coords)
  coords |> at(idx)
}

pub fn main() {
  io.debug(part1())
}
