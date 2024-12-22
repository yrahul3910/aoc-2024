from collections import deque

def mix(value, secret):
    return secret ^ value

def prune(secret):
    return secret % 16777216

def evolve(secret):
    s1 = prune(mix(secret * 64, secret))
    s2 = prune(mix(s1 // 32, s1))
    return prune(mix(s2 * 2048, s2))

def final(secret):
    for _ in range(2000):
        secret = evolve(secret)
    
    return secret

def part2(values):
    buy_options = {}

    for value in values:
        cur_secret = value
        cur_price = None
        prev_price = None
        diffs = deque()

        for _ in range(2000):
            prev_price = cur_secret % 10
            cur_secret = evolve(cur_secret)
            cur_price = cur_secret % 10

            diffs.append(cur_price - prev_price)

            if len(diffs) == 5:
                diffs.popleft()

                if tuple(diffs) not in buy_options:
                    buy_options[tuple(diffs)] = {}

                if value not in buy_options[tuple(diffs)]:
                    buy_options[tuple(diffs)][value] = cur_price

    max_sum = -1
    for buyers in buy_options.values():
        cur_sum = sum(buyers.values())

        if cur_sum > max_sum:
            max_sum = cur_sum

    return max_sum


values = [int(x) for x in open('input.txt', 'r').read().splitlines()]

def part1():
    return sum(final(secret) for secret in values)

def test_part1():
    assert part1() == 19150344884

def test_part2():
    assert part2(values) == 2121

