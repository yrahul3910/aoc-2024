import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/result
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

fn expr(e: String) -> String {
  let op_idx =
    e
    |> string.to_graphemes
    |> list.index_map(fn(x, i) { #(x, i) })
    |> list.filter(fn(t) { t.0 == "+" || t.0 == "*" })
    |> list.first
    |> result.unwrap(#("", -1))

  let parts = string.split(e, on: op_idx.0)

  let op1 = at(parts, 0) |> int.parse |> result.unwrap(0)
  let op2 = at(parts, 1) |> int.parse |> result.unwrap(0)
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
          Ok("+") | Ok("*") -> {
            io.debug(expr(acc <> val))
            expr(acc <> val)
          }
          Ok(v) -> acc <> v
          Error(_) -> panic
        }
      }
    }
  })
  |> result.unwrap("-1")
  |> int.parse
  |> result.unwrap(-1)
}

fn read_input() -> List(#(String, String)) {
  read("tiny.txt")
  |> result.unwrap("")
  |> string.split("\n")
  |> list.map(fn(row) {
    row
    |> string.split(":")
    |> fn(parts) { #(at(parts, 0), string.trim(at(parts, 1))) }
  })
}

fn run(
  inp: List(#(String, String)),
  ops: List(String),
  old_ops: Option(List(String)),
) -> Int {
  inp
  |> list.map(fn(line) {
    io.debug("---\n")
    io.debug(line)
    let target = line.0
    let candidate = line.1

    let n_spots =
      candidate |> string.to_graphemes |> list.count(fn(c) { c == " " })

    let cur_choices = ops |> list.repeat(n_spots) |> product

    let parts = candidate |> string.split(" ")

    cur_choices
    |> list.map(fn(choice) {
      case old_ops {
        option.None -> {
          let to_join =
            list.zip(parts, choice)
            |> list.map(fn(t) { [t.0, t.1] })
            |> list.flatten

          let expr =
            list.flatten([to_join, [parts |> list.last |> result.unwrap("0")]])

          io.debug(expr)

          let res = eval(expr)
          io.debug(res)
          case res == int.parse(target) |> result.unwrap(0) {
            True -> {
              res
            }
            False -> 0
          }
        }
        _ -> 0
      }
    })
    |> list.reduce(fn(acc, cur) { int.max(acc, cur) })
    |> result.unwrap(0)
  })
  |> int.sum
}

pub fn part1() {
  let inp = read_input()
  let ops = ["+", "*"]
  let old_ops = option.None

  run(inp, ops, old_ops)
}

pub fn main() {
  io.debug(part1())
}
