import itertools
from tqdm import tqdm

def _eval(lst: list[str]):
    res = lst[0]
    for i in range(len(lst[1::2])):

        if lst[2*i+1] == '|':
            res = f'{res}{lst[2*i+2]}'
        else:
            new = f'{lst[2*i + 1]}{lst[2*i+2]}'
            res = f'{eval(res + new)}'
    return int(res)

lines = open('input.txt', 'r').readlines()
lines = [x.split(':') for x in lines]
lines = [[y.strip() for y in x] for x in lines]

def run(lines: list[list[str]], choices: list[str], old_choices: list = None):
    _sum = 0
    failed = []

    ops = choices[:]
    for line in tqdm(lines):
        target = line[0]
        candidate: str = line[1]

        n_spots = candidate.count(' ')
        cur_choices = itertools.product(*([ops] * n_spots))
        parts = candidate.split(' ')

        for choice in cur_choices:
            if old_choices and all(c in old_choices for c in choice):
                continue

            to_join = [z for t in zip(parts, choice) for z in t]
            expr = to_join + [parts[-1]]
            result = _eval(expr)

            if result == int(target):
                _sum += result
                break
        else:
            failed.append(line)
    return _sum, failed

_sum1, failed = run(lines, ['+', '*'])
_sum2, _ = run(failed, ['+', '*', '|'], ['+', '*'])

print(_sum1 + _sum2)
