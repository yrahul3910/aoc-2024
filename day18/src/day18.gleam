import gleam/io
import gleam/list
import gleam/queue
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

fn bfs_helper(coords: List(#(Int, Int)), grid: List(List(Int)), q: queue.Queue(#(Int, Int, Int))) {
  let MAX = 70
  case queue.is_empty(q) {
    True -> -1
    False -> {
      let #(#(x, y, d), q) = q |> just(queue.pop_front)

      case x, y {
        MAX, MAX -> d
        _, _ -> {
          let q1 = [#(0, 1), #(1, 0), #(0, -1), #(-1, 0)]
            |> list.map(fn(t) {
              #(x + t.0, y + t.1, d + 1)
            })
            |> list.filter(fn(t) {
              t.0 >= 0 && 
              t.1 >= 0 && 
              t.0 <= MAX && 
              t.1 <= MAX && 
              at(at(grid, t.0), t.1) == 0 && 
              !list.contains(coords, #(t.0, t.1))
            })
            
           let grid = set(grid, x, y, 1)
           let q = list.flatten([queue.to_list(q), q1]) |> queue.from_list
           
           bfs_helper(coords, grid, q)
        }
      }
    }
  }
}

fn bfs(coords: List(#(Int, Int))) {
  let grid = set(mkgrid(), 0, 0, 1)
  let q = queue.from_list([#(0, 0, 0)])
  
  bfs_helper(coords, grid, q)
}

pub fn part1() {
  let coords = read_input()
  bfs(coords 
    |> list.map(fn(t) {
      #(at(t, 0), at(t, 1))
    })
    |> list.take(1024)
  )
}

fn part2_helper(coords: List(#(Int, Int))) {
  let len = coords |> list.length
  case bfs(coords) {
    d -> len
    -1 -> part2_helper(coords |> list.take(len - 1))
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

