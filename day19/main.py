from tqdm import tqdm

dp = {}

def valid(string):
    if string in dp:
        return dp[string]

    if string[0] not in pat_dict:
        return False

    res = any([
        string == w or string.startswith(w) and valid(string[len(w):])
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
for w in tqdm(want):
    dp = {}
    if valid(w):
        count += 1

print(count)
