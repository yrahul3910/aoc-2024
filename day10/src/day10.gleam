import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn unsafe_unwrap(res: Result(a, b)) -> a {
  case res {
    Ok(val) -> val
    _ -> panic as "Unwrap failed"
  }
}

fn at(lst: List(a), i: Int) -> a {
  lst
  |> list.take(i + 1)
  |> list.drop(i)
  |> list.first
  |> unsafe_unwrap
}

fn get_input() -> List(List(Int)) {
  simplifile.read("input.txt")
  |> unsafe_unwrap
  |> string.split("\n")
  |> list.map(string.to_graphemes)
  |> list.map(list.map(_, fn(cell) { int.parse(cell) |> unsafe_unwrap }))
}

fn in_bounds(grid: List(List(Int)), x: Int, y: Int) -> Bool {
  x >= 0
  && x < list.length(grid)
  && y >= 0
  && y < list.length(list.first(grid) |> unsafe_unwrap)
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

fn dfs(
  grid: List(List(Int)),
  visited: List(List(Bool)),
  score: Int,
  x: Int,
  y: Int,
  stop_on_visited: Bool,
) -> #(Int, List(List(Bool))) {
  case
    at(visited, x)
    |> at(y)
    && stop_on_visited
  {
    True -> #(score, visited)
    False -> {
      let new_visited = set(visited, x, y, True)

      case
        at(grid, x)
        |> at(y)
        == 9
      {
        True -> #(score + 1, new_visited)
        False -> {
          let explore = fn(
            dx: Int,
            dy: Int,
            current_score: Int,
            current_visited: List(List(Bool)),
          ) {
            let new_x = x + dx
            let new_y = y + dy
            case
              in_bounds(grid, new_x, new_y)
              && {
                at(grid, new_x)
                |> at(new_y)
              }
              - { at(grid, x) |> at(y) }
              == 1
            {
              True ->
                dfs(
                  grid,
                  current_visited,
                  current_score,
                  new_x,
                  new_y,
                  stop_on_visited,
                )
              False -> #(current_score, current_visited)
            }
          }

          let #(s1, v1) = explore(1, 0, score, new_visited)
          let #(s2, v2) = explore(-1, 0, s1, v1)
          let #(s3, v3) = explore(0, 1, s2, v2)
          let #(s4, v4) = explore(0, -1, s3, v3)

          #(s4, v4)
        }
      }
    }
  }
}

fn get_zeros(grid: List(List(Int))) -> List(#(Int, Int)) {
  grid
  |> list.index_map(fn(row, i) {
    row
    |> list.index_map(fn(cell, j) {
      case cell == 0 {
        True -> Ok(#(i, j))
        False -> Error(Nil)
      }
    })
    |> list.filter(fn(res) {
      case res {
        Ok(_) -> True
        Error(_) -> False
      }
    })
  })
  |> list.flatten
  |> list.map(fn(res) {
    case res {
      Ok(pos) -> pos
      _ -> panic as "Impossible"
    }
  })
}

pub fn part1() -> Int {
  let grid = get_input()
  let nr = list.length(grid)
  let nc = list.length(list.first(grid) |> unsafe_unwrap)

  get_zeros(grid)
  |> list.map(fn(t) {
    let visited = list.repeat(list.repeat(False, nc), nr)
    let #(score, _) = dfs(grid, visited, 0, t.0, t.1, True)
    score
  })
  |> int.sum
}

pub fn part2() -> Int {
  let grid = get_input()
  let nr = list.length(grid)
  let nc = list.length(list.first(grid) |> unsafe_unwrap)

  get_zeros(grid)
  |> list.map(fn(t) {
    let visited = list.repeat(list.repeat(False, nc), nr)
    let #(score, _) = dfs(grid, visited, 0, t.0, t.1, False)
    score
  })
  |> int.sum
}

pub fn main() {
  io.debug(part1())
  io.debug(part2())
}
