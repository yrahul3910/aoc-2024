import sys
from util import UnionFind
from functools import partial

def area(s: set[int]):
    return len(s)

def perimeter(s: set[int]):
    p = 0
    for val in s:
        if not interior(s, *dec(val)):
            nb = [v for v in neighbors(val) if v in s]

            p += (4 - len(nb))

    return p

# Solution by https://www.reddit.com/r/adventofcode/comments/1hcdnk0/2024_day_12_solutions/m1ruv67/
"""
We first build walls by placing "walls" one step off the cells in each set. Notably, whether these walls are in bounds doesn't actually matter: if you were to walk along the fences as described in the problem, and you had to count the edges, you would start at 1 (since you'd start along some edge), and really you only need to add to your count if you turn a corner. This is exactly what this does.

First, we classify each wall based on what kind of wall it is (is it one above a certain cell, below, to the left, or the right?) We will then sort based on these 3-tuples (wall direction, and two coordinates that we'll get to). We will iterate over these walls, keeping track of the direction and coordinates of the previous wall we looked at. The only time we don't update our count is if we're moving "right" (based on the coordinates). In any other case, we've started on a new wall going in the same direction or turned a corner.

The clever part is in how the coordinates are done. Because of the way the condition is written, it only looks for movement "right". The coordinates are chosen so that the y coordinate moves "right" (increases) along the same wall. For walls above and below a cell, this is straightforward; but for left and right walls, you swap the indices around, and suddenly the sorting naturally yields an order where you're moving "right".
"""
def edges(s: set[int]):
    walls = []
    for val in s:
        i, j = dec(val)

        if enc(i - 1, j) not in s:  # up
            walls.append((1, i - 1, j))
        if enc(i + 1, j) not in s:  # down
            walls.append((2, i, j))
        if enc(i, j - 1) not in s:  # left
            walls.append((3, j - 1, i))
        if enc(i, j + 1) not in s:  # right
            walls.append((4, j, i))

    p = pd = pi = pj = 0
    for (d, i, j) in sorted(walls):
        if d != pd or i != pi or j != pj+1:
            p += 1
        pd, pi, pj = d, i, j

    return p

def idx_to_int(n: int, i: int, j: int):
    return i * n + j

def int_to_idx(n: int, i: int):
    return i // n, i % n

def is_interior(m: int, n: int, s: set[int], i: int, j: int):
    return (i > 0 and enc(i - 1, j) in s) and (j > 0 and enc(i, j - 1) in s) and (
            i < m and enc(i+1, j) in s) and (j < n - 1 and enc(i, j+1) in s)

def valid(m: int, n: int, i: int, j: int):
    return i >= 0 and i < m and j >= 0 and j < n

def neighbors(idx: int):
    i, j = dec(idx)
    n = []
    
    if inb(i + 1, j):
        n.append(enc(i+1, j))
    if inb(i - 1, j):
        n.append(enc(i - 1, j))
    if inb(i, j+1):
        n.append(enc(i, j+1))
    if inb(i, j-1):
        n.append(enc(i, j-1))

    return n

grid = [list(line.strip()) for line in open(sys.argv[-1], 'r').readlines()]
m, n = len(grid), len(grid[0])
dsu = UnionFind(m * n)
enc = partial(idx_to_int, n)
dec = partial(int_to_idx, n)
inb = partial(valid, m, n)
interior = partial(is_interior, m, n)

for i in range(m):
    for j in range(n):
        if inb(i + 1, j) and grid[i][j] == grid[i+1][j]:
            dsu.merge(enc(i, j), enc(i+1, j))
        if inb(i, j + 1) and grid[i][j] == grid[i][j+1]:
            dsu.merge(enc(i, j), enc(i, j+1))

sets = dsu.finalize()

def part1():
    return sum(area(s) * perimeter(s) for s in sets)

def part2():
    return sum(area(s) * edges(s) for s in sets)

def test_part1():
    assert part1() == 1450816

def test_part2():
    assert part2() == 865662
