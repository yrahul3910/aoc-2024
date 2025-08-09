import itertools
import sys
from pprint import pprint

UP, RIGHT, LEFT, DOWN = '^', '>', '<', 'v'

l0 = {}
for i, j in itertools.combinations(range(10), 2):
    if i > j:
        i, j = j, i
    up = (j - i) // 3
    right = (j - i) % 3
    if (i %3 == 2 and j % 3 == 1) or (i % 3 == 0 and j % 3 != 0):
        right -= 3  # make it negative
        up += 1
    l0[(i, j)] = [*(abs(right) * (RIGHT if right >= 0 else LEFT)), *(up * UP)]

RMAP = {LEFT: RIGHT, RIGHT: LEFT, UP: DOWN, DOWN: UP}
for i, j in l0.copy().keys():
    if i < j:
        l0[(j, i)] = [RMAP[c] for c in l0[(i, j)][::-1]]

l0[('A', 0)] = [LEFT]
l0[(0, 'A')] = [RIGHT]
for i in range(1, 10):
    l0[(i, i)] = []
    l0[(0, i)] = [UP] + sorted(l0[(2, i)], reverse=True)  # ASCII ^ is greater than < and >, so favor those first.
    l0[(i, 0)] = sorted(l0[(i, 2)] + [DOWN])  # v is greatest, so do them last.
    if i not in [3, 6, 9]:
        l0[('A', i)] = [*((i // 3 + 1) * UP)] + l0[3 * (i // 3 + 1), i]
    else:
        l0[('A', i)] = [*(i // 3 * UP)]
    l0[(i, 'A')] = [RMAP[c] for c in l0[('A', i)][::-1]]

# Handle special cases
# Isn't it fucking great that v v > is better than > v v but the same isn't true if left is swapped with right?
l0[(2, 'A')] = [DOWN, RIGHT]  # Faster than > v
l0[(5, 'A')] = [DOWN, DOWN, RIGHT]
l0[(8, 'A')] = [DOWN, DOWN, DOWN, RIGHT]
l0[(5, 1)] = [LEFT, DOWN]
l0[(6, 1)] = [LEFT, LEFT, DOWN]
l0[(6, 2)] = [LEFT, DOWN]
l0[(8, 1)] = [LEFT, DOWN, DOWN]
l0[(8, 4)] = [LEFT, DOWN]
l0[(9, 1)] = [LEFT, LEFT, DOWN, DOWN]
l0[(9, 2)] = [LEFT, DOWN, DOWN]
l0[(9, 4)] = [LEFT, LEFT, DOWN]
l0[(9, 5)] = [LEFT, DOWN]
pprint(l0)
print()

l1 = {}
L1_MAP = {'<': 1, 'v': 2, '>': 3, '^': 5, 'A': 6} 
L1_REV_MAP = {v: k for k, v in L1_MAP.items()}
for i, j in itertools.combinations(L1_MAP.keys(), 2):
    l1[(i, j)] = l0[(L1_MAP[i], L1_MAP[j])]
    l1[(j, i)] = l0[(L1_MAP[j], L1_MAP[i])]

# Special cases
l1[('A', DOWN)] = [LEFT, DOWN]

pprint(l1)

l2 = l1.copy()

codes = open(sys.argv[-1]).read().splitlines()
_sum = 0
for code in codes:
    print(code)
    l0_ops = l0[('A', int(code[0]))] + ['A']
    for i, c in enumerate(code[:-2]):
        if c != code[i + 1]:
            l0_ops.extend(l0[int(c), int(code[i + 1])] + ['A'])
        else:
            l0_ops.append('A')
    l0_ops.extend(l0[(int(code[-2]), 'A')])
    l0_ops.append('A')

    l1_ops = l1[('A', l0_ops[0])] + ['A']
    for i, c in enumerate(l0_ops[:-1]):
        if c != l0_ops[i + 1]:
            l1_ops.extend(l1[(c, l0_ops[i + 1])] + ['A'])
        else:
            l1_ops.append('A')

    l2_ops = l2[('A', l1_ops[0])] + ['A']
    for i, c in enumerate(l1_ops[:-1]):
        if c != l1_ops[i + 1]:
            l2_ops.extend(l2[(c, l1_ops[i + 1])] + ['A'])
        else:
            l2_ops.append('A')

    print(l0_ops)
    print(l1_ops)
    print(''.join(l2_ops))
    _sum += len(l2_ops) * int(code[:-1])
    print(len(l2_ops), '*', int(code[:-1]))
    print()

print(_sum)


l0_ops = [UP, UP, LEFT]
l1_ops = l1[('A', l0_ops[0])] + ['A']
for i, c in enumerate(l0_ops[:-1]):
    if c != l0_ops[i + 1]:
        l1_ops.extend(l1[(c, l0_ops[i + 1])] + ['A'])
    else:
        l1_ops.append('A')

l2_ops = l2[('A', l1_ops[0])] + ['A']
for i, c in enumerate(l1_ops[:-1]):
    if c != l1_ops[i + 1]:
        l2_ops.extend(l2[(c, l1_ops[i + 1])] + ['A'])
    else:
        l2_ops.append('A')
print(len(l2_ops))

l0_ops = [LEFT, UP, UP]
l1_ops = l1[('A', l0_ops[0])] + ['A']
for i, c in enumerate(l0_ops[:-1]):
    if c != l0_ops[i + 1]:
        l1_ops.extend(l1[(c, l0_ops[i + 1])] + ['A'])
    else:
        l1_ops.append('A')
l2_ops = l2[('A', l1_ops[0])] + ['A']
for i, c in enumerate(l1_ops[:-1]):
    if c != l1_ops[i + 1]:
        l2_ops.extend(l2[(c, l1_ops[i + 1])] + ['A'])
    else:
        l2_ops.append('A')
print(len(l2_ops))
