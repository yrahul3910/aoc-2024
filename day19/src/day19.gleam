import gleam/dict
import gleam/int
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

fn get_input() -> #(List(String), List(String)) {
  read("input.txt")
  |> unsafe_unwrap
  |> string.split("\n\n")
  |> fn(t) { #(at(t, 0) |> string.split(", "), at(t, 1) |> string.split("\n")) }
}

fn get_pat_dict(patterns: List(String)) -> dict.Dict(String, List(String)) {
  patterns
  |> list.map(fn(s) { #(string.first(s) |> unsafe_unwrap, s) })
  |> list.group(fn(t) { t.0 })
  |> dict.map_values(fn(_, t: List(#(String, String))) {
    t |> list.map(fn(t) { t.1 })
  })
}

fn valid_part1(
  s: String,
  pat_dict: dict.Dict(String, List(String)),
  dp: dict.Dict(String, Bool),
) -> #(Bool, dict.Dict(String, Bool)) {
  case string.length(s) == 0 {
    True -> #(True, dp)
    False -> {
      case dict.has_key(dp, s) {
        True -> #(dict.get(dp, s) |> unsafe_unwrap, dp)
        False -> {
          case dict.has_key(pat_dict, s |> string.first |> unsafe_unwrap) {
            False -> #(False, dict.insert(dp, s, False))
            True -> {
              let res =
                dict.get(pat_dict, s |> string.first |> unsafe_unwrap)
                |> unsafe_unwrap

              let #(total, final_dp) =
                res
                |> list.fold(#(False, dp), fn(t, w) {
                  let #(val, d) = t
                  let recursed =
                    valid_part1(
                      string.drop_start(s, string.length(w)),
                      pat_dict,
                      d,
                    )

                  case string.starts_with(s, w) {
                    True -> #(val || recursed.0, recursed.1)
                    False -> #(val, dict.insert(recursed.1, s, val))
                  }
                })

              #(total, dict.insert(final_dp, s, total))
            }
          }
        }
      }
    }
  }
}

fn valid_part2(
  s: String,
  pat_dict: dict.Dict(String, List(String)),
  dp: dict.Dict(String, Int),
) -> #(Int, dict.Dict(String, Int)) {
  case string.length(s) == 0 {
    True -> #(1, dp)
    False -> {
      case dict.has_key(dp, s) {
        True -> #(dict.get(dp, s) |> unsafe_unwrap, dp)
        False -> {
          case dict.has_key(pat_dict, s |> string.first |> unsafe_unwrap) {
            False -> #(0, dict.insert(dp, s, 0))
            True -> {
              let res =
                dict.get(pat_dict, s |> string.first |> unsafe_unwrap)
                |> unsafe_unwrap

              let #(total, final_dp) =
                res
                |> list.fold(#(0, dp), fn(t, w) {
                  let #(val, d) = t
                  let recursed =
                    valid_part2(
                      string.drop_start(s, string.length(w)),
                      pat_dict,
                      d,
                    )

                  case string.starts_with(s, w) {
                    True -> #(val + recursed.0, recursed.1)
                    False -> #(val, dict.insert(recursed.1, s, val))
                  }
                })

              #(total, dict.insert(final_dp, s, total))
            }
          }
        }
      }
    }
  }
}

pub fn part1() {
  let #(patterns, want) = get_input()
  let pat_dict = get_pat_dict(patterns)
  let dp: dict.Dict(String, Bool) = dict.new()

  want
  |> list.filter(fn(w) { string.length(w) > 0 })
  |> list.map(fn(w) { valid_part1(w, pat_dict, dp).0 })
  |> list.filter(fn(b) { b })
  |> list.length
}

pub fn part2() {
  let #(patterns, want) = get_input()
  let pat_dict = get_pat_dict(patterns)
  let dp: dict.Dict(String, Int) = dict.new()

  want
  |> list.filter(fn(w) { string.length(w) > 0 })
  |> list.map(fn(w) { valid_part2(w, pat_dict, dp).0 })
  |> int.sum
}

pub fn main() {
  io.debug(part1())
  io.debug(part2())
}
