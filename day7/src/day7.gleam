import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

fn product(lists: List(List(a))) -> List(List(a)) {
  case lists {
    [] ->
      // If no lists, return an empty list
      []
    [first, ..rest] ->
      case product(rest) {
        [] ->
          // Base case: if there are no more lists to combine, return the first list wrapped in a list of lists
          list.map(first, fn(x) { [x] })
        combinations ->
          // Combine the current list with the combinations of the rest
          list.flat_map(first, fn(x) {
            list.map(combinations, fn(combo) { list.append([x], combo) })
          })
      }
  }
}

fn at(lst: List(a), i: Int) -> a {
  lst
  |> list.take(i + 1)
  |> list.drop(i)
  |> list.first
  |> fn(r) {
    case r {
      Ok(val) -> val
      Error(_) -> panic
    }
  }
}

fn unsafe_unwrap(res: Result(a, b)) -> a {
  case res {
    Ok(val) -> val
    _ -> panic
  }
}

fn just(inp: a, func: fn(a) -> Result(b, c)) -> b {
  inp
  |> func
  |> unsafe_unwrap
}

fn expr(e: String) -> String {
  let op_idx =
    e
    |> string.to_graphemes
    |> list.index_map(fn(x, i) { #(x, i) })
    |> list.filter(fn(t) { t.0 == "+" || t.0 == "*" })
    |> just(list.first)

  let parts = string.split(e, on: op_idx.0)

  let op1 = at(parts, 0) |> just(int.parse)
  let op2 = at(parts, 1) |> just(int.parse)
  case op_idx.0 {
    "+" -> int.to_string(op1 + op2)
    "*" -> int.to_string(op1 * op2)
    _ -> panic
  }
}

fn eval(lst: List(String)) -> Int {
  lst
  |> list.reduce(fn(acc, cur) {
    case cur {
      "+" | "*" -> acc <> cur
      "|" -> acc
      val -> {
        case string.last(acc) {
          Ok("+") | Ok("*") -> expr(acc <> val)
          Ok(_) -> acc <> cur
          Error(_) -> panic
        }
      }
    }
  })
  |> unsafe_unwrap
  |> just(int.parse)
}

fn read_input() -> List(#(String, String)) {
  "tiny.txt"
  |> just(read)
  |> string.split("\n")
  |> list.map(fn(row) {
    row
    |> string.split(":")
    |> fn(parts) { #(at(parts, 0), string.trim(at(parts, 1))) }
  })
}

fn run(inp: List(#(String, String)), ops: List(String)) -> Int {
  inp
  |> list.map(fn(line) {
    let target = line.0
    let candidate = line.1

    let n_spots =
      candidate |> string.to_graphemes |> list.count(fn(c) { c == " " })

    let cur_choices = ops |> list.repeat(n_spots) |> product
    let parts = candidate |> string.split(" ")

    cur_choices
    |> list.map(fn(choice) {
      let to_join =
        list.zip(parts, choice)
        |> list.map(fn(t) { [t.0, t.1] })
        |> list.flatten

      let expr = list.flatten([to_join, [parts |> just(list.last)]])

      let res = eval(expr)
      case res == target |> just(int.parse) {
        True -> res
        False -> 0
      }
    })
    |> list.reduce(fn(acc, cur) { int.max(acc, cur) })
    |> unsafe_unwrap
  })
  |> int.sum
}

pub fn part1() {
  let inp = read_input()
  let ops = ["+", "*"]

  run(inp, ops)
}

pub fn part2() {
  let inp = read_input()
  let ops = ["+", "*", "|"]

  run(inp, ops)
}

pub fn main() {
  io.debug(part1())
  io.debug(part2())
}
