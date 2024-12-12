import gleam/dict
import gleam/int
import gleam/io
import gleam/list
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

fn evolve(arr: List(#(Int, Int)), dp: dict.Dict(Int, List(#(Int, Int)))) {
  let ctr: dict.Dict(Int, Int) =
    arr
    |> list.group(fn(t) { t.0 })
    |> dict.map_values(fn(_k, lt) {
      lt
      |> list.map(fn(t) { t.1 })
      |> int.sum
    })

  let n = arr |> list.length

  case n {
    0 -> #([], dp)
    1 -> {
      let value = arr |> just(list.first) |> fn(t) { t.0 }

      case dict.has_key(dp, value) {
        True -> dp |> dict.get(value) |> unsafe_unwrap |> fn(v) { #(v, dp) }
        False -> {
          let s = int.to_string(value)
          let m = string.length(s)

          let m2 = int.floor_divide(m, 2) |> unsafe_unwrap

          let s0 = string.slice(s, 0, m2)
          let s1 = string.drop_start(s, m2)

          case m % 2 == 0 {
            True -> {
              let new_dp =
                dp
                |> dict.insert(value, [
                  #(int.parse(s0) |> unsafe_unwrap, 1),
                  #(int.parse(s1) |> unsafe_unwrap, 1),
                ])

              #(new_dp |> dict.get(value) |> unsafe_unwrap, new_dp)
            }
            False -> {
              let v = value * 2024
              let new_dp =
                dp
                |> dict.insert(value, [#(v, 1)])

              #(new_dp |> dict.get(value) |> unsafe_unwrap, new_dp)
            }
          }
        }
      }
    }
    _ -> {
      let cur_items =
        ctr
        |> dict.to_list

      cur_items
      |> list.fold(#([], dp), fn(acc, cur) {
        // We map to #(items_so_far, dp)
        let #(res, new_dp) = evolve([cur], acc.1)
        let updated_items =
          res
          |> list.map(fn(t: #(Int, Int)) { #(t.0, t.1 * cur.1) })

        #(list.flatten([acc.0, updated_items]), new_dp)
      })
      |> fn(t) {
        let res = t.0
        let new_dp = t.1

        let updated_items =
          res
          |> list.group(fn(t) { t.0 })
          |> dict.to_list
          |> list.map(fn(u) {
            #(u.0, u.1 |> list.map(fn(v) { v.1 }) |> int.sum)
          })

        #(updated_items, new_dp)
      }
    }
  }
}

fn part1_helper(
  input: List(#(Int, Int)),
  dp: dict.Dict(Int, List(#(Int, Int))),
  n: Int,
  items: List(#(Int, Int)),
) {
  case n == 0 {
    True -> items
    False -> {
      let #(updated_items, new_dp) = evolve(input, dp)

      part1_helper(updated_items, new_dp, n - 1, updated_items)
    }
  }
}

fn get_input() {
  read("input.txt")
  |> unsafe_unwrap
  |> string.trim
  |> string.split(" ")
  |> list.map(fn(s) { s |> just(int.parse) })
}

pub fn part1() {
  let input = get_input()

  let dp = dict.from_list([#(0, [#(1, 1)])])
  let arr =
    input
    |> list.map(fn(i) { #(i, 1) })

  part1_helper(arr, dp, 25, [])
  |> list.map(fn(t) { t.1 })
  |> int.sum
}

pub fn part2() {
  let input = get_input()

  let dp = dict.from_list([#(0, [#(1, 1)])])
  let arr =
    input
    |> list.map(fn(i) { #(i, 1) })

  part1_helper(arr, dp, 75, [])
  |> list.map(fn(t) { t.1 })
  |> int.sum
}

pub fn main() {
  io.debug(part1())
  io.debug(part2())
}
