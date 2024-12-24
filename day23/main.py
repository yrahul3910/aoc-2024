import itertools
import random


computers, connections = set(), set()
max_clique = set()
for line in open('input.txt'):
    a, b = line.strip().split('-')
    computers.update([a, b])
    connections.update([(a,b), (b,a)])


def neighbors(u: str):
    return set(t[1] for t in connections if t[0] == u)


def bron_kerbosch(R: set, P: set, X: set):
    global max_clique

    if not P and not X:
        if len(R) >= len(max_clique):
            max_clique = R
        return

    u = random.choice(list(P | X))
    for v in P - neighbors(u):
        bron_kerbosch(R | {v}, P & neighbors(v), X & neighbors(v))
        P = P - {v}
        X = X | {v}


def part1():
    return sum({(a,b), (b,c), (c,a)} < connections
              and 't' in (a + b + c)[::2]
              for a, b, c in itertools.combinations(computers, 3))


def part2():
    bron_kerbosch(set(), computers.copy(), set())
    return ','.join(sorted(max_clique))


def test_part1():
    assert part1() == 1248


def test_part2():
    assert part2() == 'aa,cf,cj,cv,dr,gj,iu,jh,oy,qr,xr,xy,zb'

print(part2())
