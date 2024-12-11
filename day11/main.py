dp = {0: ([1], 1)}

def evolve(arr):
    n = len(arr)
    if n == 0:
        return ([], 0)
    if n == 1:
        if arr[0] in dp:
            return dp[arr[0]]
        if len(f"{arr[0]}") % 2 == 0:
            s = str(arr[0])
            m = len(s)
            dp[arr[0]] = ([int(s[:m//2]), int(s[m//2:])], 2)
            return dp[arr[0]]
        else:
            v = arr[0] * 2024
            dp[arr[0]] = ([v], 1)

    p1 = evolve(arr[:n//2])
    p2 = evolve(arr[n//2:])
    return [*(p1[0]), *(p2[0])], p1[1] + p2[1]

def p1(arr):
    a = arr[:]
    for _ in range(75):
        print(f"it {_}")
        a, s = evolve(a)
    print(s)

p1([125, 17])

arr = [int(x) for x in open("input.txt", "r").read().split(" ")]
p1(arr)

# buf = ["x" for _ in range(65535)]
# buf = open('tiny.txt', 'r').read().split(" ")
#
# for _ in range(25):
#     print(f"{_ = }")
#     for i, v in enumerate(buf):
#         if v == "x":
#             break
#
#         val = int(v)
#
#         if val == 0:
#             buf[i] = "1"
#         elif len(v) & 1:
#             buf[i] = f"{2024*val}"
#         else:
#             buf = buf[:i] + [v[:len(v)//2], v[len(v)//2:]] + buf[i+1:]
#
# print(len(buf))
