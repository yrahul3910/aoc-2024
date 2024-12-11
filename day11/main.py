dp = {0: [(1, 1)]}

def evolve(arr):
    ctr = {}
    for val, ct in arr:
        ctr[val] = ctr.get(val, 0) + ct

    n = len(arr)
    if n == 0:
        return []
    if n == 1:
        value = arr[0][0]
        if value in dp:
            return dp[value]
        if len((s := str(value))) % 2 == 0:
            m = len(s)
            dp[value] = [(int(s[:m//2]), 1), (int(s[m//2:]), 1)]
            return dp[value]
        else:
            v = value * 2024
            dp[value] = [(v, 1)]
            return dp[value]

    items = {}
    for v, c in ctr.items():
        res = evolve([(v, c)])
        for el, _c in res:
            items[el] = items.get(el, 0) + _c * c

        if v not in dp:
            dp[v] = res

    return list(items.items())

def p1(arr):
    a = [(x, 1) for x in arr]
    for _ in range(75):
        print(f"it {_}")
        a = evolve(a)
    print(sum([x[1] for x in a]))

arr = [int(x) for x in open("input.txt", "r").read().split(" ")]
p1(arr)

