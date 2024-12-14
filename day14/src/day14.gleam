import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/string
import simplifile.{append, read}

pub fn unsafe_unwrap(res: Result(a, b)) -> a {
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

fn fd(m: Int, n: Int) -> Int {
  int.floor_divide(m, n) |> unsafe_unwrap
}

fn get_input() -> #(List(#(Int, Int)), List(#(Int, Int)), Int, Int) {
  let lines =
    read("input.txt")
    |> unsafe_unwrap
    |> string.split("\n")
    |> list.map(string.trim)

  let #(pos, vel) =
    lines
    |> list.map(fn(line) {
      let rgx = regexp.from_string("-?\\d+") |> unsafe_unwrap
      let vals = regexp.scan(rgx, line) |> list.map(fn(m) { m.content })
      let pos = #(
        vals |> at(0) |> just(int.parse),
        vals |> at(1) |> just(int.parse),
      )
      let vel = #(
        vals |> at(2) |> just(int.parse),
        vals |> at(3) |> just(int.parse),
      )

      #(pos, vel)
    })
    |> list.unzip

  #(pos, vel, 100, 102)
}

pub fn part1() {
  let #(pos, vel, m, n) = get_input()
  let newp =
    list.zip(pos, vel)
    |> list.map(fn(t) {
      #(
        int.modulo(t.0.0 + 100 * t.1.0, m + 1) |> unsafe_unwrap,
        int.modulo(t.0.1 + 100 * t.1.1, n + 1) |> unsafe_unwrap,
      )
    })

  let midr = case int.bitwise_and(m, 1) {
    1 -> -1
    0 -> fd(m, 2)
    _ -> panic
  }
  let midc = case int.bitwise_and(n, 1) {
    1 -> -1
    0 -> fd(n, 2)
    _ -> panic
  }

  let counted =
    newp
    |> list.filter(fn(t) { t.0 != midr && t.1 != midc })
  let q0 =
    counted
    |> list.filter(fn(t) { t.0 <= fd(m, 2) && t.1 <= fd(n, 2) })
    |> list.length
  let q1 =
    counted
    |> list.filter(fn(t) { t.0 > fd(m, 2) && t.1 <= fd(n, 2) })
    |> list.length
  let q2 =
    counted
    |> list.filter(fn(t) { t.0 <= fd(m, 2) && t.1 > fd(n, 2) })
    |> list.length
  let q3 =
    counted
    |> list.filter(fn(t) { t.0 > fd(m, 2) && t.1 > fd(n, 2) })
    |> list.length

  q0 * q1 * q2 * q3
}

fn print(arr: List(#(Int, Int)), m: Int, n: Int) {
  list.range(0, n)
  |> list.map(fn(i) {
    list.range(0, m)
    |> list.map(fn(j) {
      case list.contains(arr, #(j, i)) {
        True -> {
          append("out.txt", "+")
        }
        False -> {
          append("out.txt", ".")
        }
      }
    })
    append("out.txt", "\n")
  })
}

fn part2_helper(
  pos: List(#(Int, Int)),
  vel: List(#(Int, Int)),
  m: Int,
  n: Int,
  i: Int,
) {
  case i < 6533 {
    // For the actual puzzle, change this to 10k
    False -> Nil
    True -> {
      let newp =
        list.zip(pos, vel)
        |> list.map(fn(t) {
          #(
            int.modulo(t.0.0 + i * t.1.0, m + 1) |> unsafe_unwrap,
            int.modulo(t.0.1 + i * t.1.1, n + 1) |> unsafe_unwrap,
          )
        })

      print(newp, m, n)
      part2_helper(pos, vel, m, n, i + 1)
    }
  }
}

pub fn part2() {
  let #(pos, vel, m, n) = get_input()
  // For the actual puzzle, change this to 1
  let i = 6532

  let newp =
    list.zip(pos, vel)
    |> list.map(fn(t) {
      #(
        int.modulo(t.0.0 + i * t.1.0, m + 1) |> unsafe_unwrap,
        int.modulo(t.0.1 + i * t.1.1, n + 1) |> unsafe_unwrap,
      )
    })

  print(newp, m, n)
}

pub fn main() {
  io.debug(part1())
  io.debug(part2())
}
