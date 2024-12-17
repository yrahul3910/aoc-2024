use std::fs;

fn cmb(op: u64, ax: u64, bx: u64, cx: u64) -> u64 {
    match op {
        0..=3 => op,
        4 => ax,
        5 => bx,
        6 => cx,
        _ => unreachable!(),
    }
}

fn run(prog: &[u64], a: u64) -> Vec<u64> {
    let mut ax = a;
    let mut bx = 0;
    let mut cx = 0;

    let mut i: i64 = 0;
    let mut res: Vec<u64> = Vec::new();

    while i < prog.len() as i64 {
        match (prog[i as usize], prog[(i + 1) as usize]) {
            (0, op) => ax >>= cmb(op, ax, bx, cx),
            (1, op) => bx ^= op,
            (2, op) => bx = 0x7 & cmb(op, ax, bx, cx),
            (3, op) => i = if ax != 0 { op as i64 - 2 } else { i },
            (4, _o) => bx ^= cx,
            (5, op) => res.push(cmb(op, ax, bx, cx) & 0x7),
            (6, op) => bx = ax >> cmb(op, ax, bx, cx),
            (7, op) => cx = ax >> cmb(op, ax, bx, cx),
            _ => unreachable!(),
        }
        i += 2;
    }

    res
}

fn part2() -> Vec<u64> {
    let filename = "input.txt";
    let contents = fs::read_to_string(filename).expect("File I/O error");
    let prog = contents
        .split('\n')
        .last()
        .unwrap()
        .split(':')
        .last()
        .unwrap()
        .split(',')
        .map(|x| x.trim().parse::<u64>().unwrap())
        .collect::<Vec<u64>>();

    let mut results: Vec<u64> = Vec::new();
    let mut todo: Vec<(i64, u64)> = vec![(-1, 0)];
    while let Some((i, a)) = todo.pop() {
        for ax in a..a + 8 {
            let len = prog.len() as i64;
            if run(&prog, ax) == prog[(len + i.max(-len)) as usize..] {
                todo.push((i - 1, ax * 8));

                if i == -(prog.len() as i64) {
                    println!("ax = {}", ax);
                    results.push(ax);
                }
            }
        }
    }

    results
}

pub fn main() {
    part2();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part2_works() {
        let results = part2();
        assert!(results.contains(&109019476330651));
    }
}
