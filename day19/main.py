dp = {}

# Part 1: fn = any; part 2: fn = sum
def valid(string, fn=sum):
    if string in dp:
        return dp[string]

    if string[0] not in pat_dict:
        return False

    res = fn([
        string == w or string.startswith(w) and valid(string[len(w):], fn)
        for w in pat_dict[string[0]]
    ])
    dp[string] = res

    return res

patterns, *want = open('input.txt').read().split("\n")
patterns = patterns.split(", ")
want = want[1:-1]

pat_dict = {
    chr(c): [p for p in patterns if p.startswith(chr(c))]
    for c in range(97, 123)
}
pat_dict = { k: v for k, v in pat_dict.items() if v }

count = 0
for w in want:
    dp = {}
    count += valid(w)

print(count)
