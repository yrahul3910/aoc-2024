import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/string
import simplifile.{read}

fn unsafe_unwrap(res: Result(a, b)) -> a {
  case res {
    Ok(val) -> val
    _ -> panic as "Unwrap failed"
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

fn get_input() {
  read("input.txt")
  |> unsafe_unwrap
  |> string.split("\n\n")
}

pub fn part1() {
  get_input()
  |> list.map(fn(part) {
    let rgx =
      regexp.compile("\\d+", with: regexp.Options(False, True))
      |> unsafe_unwrap

    let vars =
      regexp.scan(rgx, part)
      |> list.map(fn(match) { match.content |> just(int.parse) })

    let a1 = at(vars, 0)
    let b1 = at(vars, 2)
    let c1 = at(vars, 4)
    let a2 = at(vars, 1)
    let b2 = at(vars, 3)
    let c2 = at(vars, 5)

    let det = a1 * b2 - a2 * b1
    case det == 0 {
      True -> 0
      False -> {
        let x =
          float.divide(int.to_float(c1 * b2 - c2 * b1), int.to_float(det))
          |> unsafe_unwrap
        let y =
          float.divide(int.to_float(a1 * c2 - a2 * c1), int.to_float(det))
          |> unsafe_unwrap

        case
          int.to_float(float.round(x)) == x && int.to_float(float.round(y)) == y
        {
          True -> 3 * float.round(x) + float.round(y)
          False -> 0
        }
      }
    }
  })
  |> int.sum
}

pub fn part2() {
  get_input()
  |> list.map(fn(part) {
    let rgx =
      regexp.compile("\\d+", with: regexp.Options(False, True))
      |> unsafe_unwrap

    let vars =
      regexp.scan(rgx, part)
      |> list.map(fn(match) { match.content |> just(int.parse) })

    let a1 = at(vars, 0)
    let b1 = at(vars, 2)
    let c1 = at(vars, 4) + 10_000_000_000_000
    let a2 = at(vars, 1)
    let b2 = at(vars, 3)
    let c2 = at(vars, 5) + 10_000_000_000_000

    let det = a1 * b2 - a2 * b1
    case det == 0 {
      True -> 0
      False -> {
        let x =
          float.divide(int.to_float(c1 * b2 - c2 * b1), int.to_float(det))
          |> unsafe_unwrap
        let y =
          float.divide(int.to_float(a1 * c2 - a2 * c1), int.to_float(det))
          |> unsafe_unwrap

        case
          int.to_float(float.round(x)) == x && int.to_float(float.round(y)) == y
        {
          True -> 3 * float.round(x) + float.round(y)
          False -> 0
        }
      }
    }
  })
  |> int.sum
}

pub fn main() {
  io.debug(part1())
  io.debug(part2())
}
