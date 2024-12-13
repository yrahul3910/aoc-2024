import re


lines = open('input.txt', 'r').read()
parts = lines.split("\n\n")

_sum = 0
for part in parts:
    vars = [int(x) for x in re.findall(r"\d+", part)]

    a1 = vars[0]
    b1 = vars[2]
    c1 = vars[4]
    a2 = vars[1]
    b2 = vars[3]
    c2 = vars[5]

    c1 += 10000000000000
    c2 += 10000000000000

    det = a1 * b2 - a2 * b1
    print(f"{det = }")

    if det != 0:
        x = (c1 * b2 - c2 * b1) / det
        y = (a1 * c2 - a2 * c1) / det

        print(f"{x = }, {y = }")

        if x == int(x) and y == int(y):
            _sum += 3 * x + y

print(_sum)

