import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

fn read_input() -> #(List(String), List(String)) {
  read("input.txt")
  |> result.unwrap("")
  |> string.split_once("\n\n")
  |> result.unwrap(#("", ""))
  |> fn(t) { #(string.split(t.0, "\n"), string.split(t.1, "\n")) }
}

fn get_order(ord: List(String)) -> dict.Dict(String, List(String)) {
  list.map(ord, string.split_once(_, "|"))
  |> list.map(result.unwrap(_, #("", "")))
  |> list.group(fn(t) { t.0 })
  |> dict.map_values(fn(_, v) { list.map(v, fn(t) { t.1 }) })
}

fn get_queries(q: List(String)) -> List(List(String)) {
  list.map(q, string.split(_, ","))
}

pub fn part1() -> Int {
  let inp = read_input()
  let order = get_order(inp.0)
  let queries = get_queries(inp.1)

  list.filter_map(queries, fn(q) {
    let is_in_order =
      q
      |> list.map(is_single_query_in_order(_, q, order))
      |> list.all(fn(x) { x })

    case is_in_order {
      True -> {
        let idx =
          q
          |> list.length
          |> int.floor_divide(2)
          |> result.unwrap(0)

        list.first(list.drop(q, idx))
      }
      False -> Error(Nil)
    }
  })
  |> list.map(int.parse)
  |> list.map(result.unwrap(_, 0))
  |> int.sum
}

fn find(lst: List(a), val: a) -> Int {
  lst
  |> list.index_map(fn(el, i) { #(el, i) })
  |> list.key_find(val)
  |> result.unwrap(-1)
}

fn is_single_query_in_order(
  q: String,
  query: List(String),
  ord: dict.Dict(String, List(String)),
) -> Bool {
  let idx = find(query, q)
  let rest = list.drop(query, idx + 1)

  rest
  |> list.map(fn(r) { list.contains(result.unwrap(dict.get(ord, q), []), r) })
  |> list.all(fn(x) { x })
}

fn repair_once(
  query: List(String),
  ord: dict.Dict(String, List(String)),
) -> List(String) {
  let failing =
    query
    |> list.filter(fn(q) {
      bool.negate(is_single_query_in_order(q, query, ord))
    })
    |> list.first
    |> result.unwrap("")

  let i = find(query, failing)
  let to_swap =
    query
    |> list.drop(i + 1)
    |> list.filter(fn(q) {
      bool.negate({
        let tmp =
          dict.get(ord, failing)
          |> result.unwrap([])

        list.contains(tmp, q)
      })
    })
    |> list.first
    |> result.unwrap("")

  swap(query, failing, to_swap)
}

fn repair(query: List(String), ord: dict.Dict(String, List(String))) {
  let needs_repair =
    query
    |> list.map(is_single_query_in_order(_, query, ord))
    |> list.all(fn(x) { x })

  case needs_repair {
    True -> query
    False -> repair(repair_once(query, ord), ord)
  }
}

fn swap(lst: List(a), val1: a, val2: a) -> List(a) {
  let i = find(lst, val1)
  let j = find(lst, val2)

  list.flatten([
    list.take(lst, i),
    // lst[..i]
    list.drop(list.take(lst, j + 1), j),
    // lst[j]
    list.drop(list.take(lst, j), i + 1),
    // lst[i+1..j-1]
    list.drop(list.take(lst, i + 1), i),
    // lst[i]
    list.drop(lst, j + 1),
    // lst[j+1..]
  ])
}

pub fn part2() -> Int {
  let inp = read_input()
  let order = get_order(inp.0)
  let queries = get_queries(inp.1)

  let failing_queries =
    queries
    |> list.filter(fn(query) {
      list.map(query, is_single_query_in_order(_, query, order))
      |> list.all(fn(x) { x })
      |> bool.negate
    })
    |> list.map(repair(_, order))

  list.filter_map(failing_queries, fn(q) {
    let idx =
      q
      |> list.length
      |> int.floor_divide(2)
      |> result.unwrap(0)

    list.first(list.drop(q, idx))
  })
  |> list.map(int.parse)
  |> list.map(result.unwrap(_, 0))
  |> int.sum
}

pub fn main() {
  io.debug(part1())
  io.debug(part2())
}
