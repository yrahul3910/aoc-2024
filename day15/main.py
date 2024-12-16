import sys


def inb(grid, i, j):
    return i >= 0 and i < len(grid) and j >= 0 and j < len(grid[0])


content = open(sys.argv[-1]).read()
grid, moves = content.split("\n\n")

grid = [list(c.strip()) for c in grid.split("\n")]
r = [i for i, row in enumerate(grid) if '@' in row][0]
c = [j for j, cell in enumerate(grid[r]) if cell == '@'][0]
d = {
    ">": (0, 1),
    "<": (0, -1),
    "^": (-1, 0),
    "v": (1, 0)
}

for move in moves:
    print(move)
    dx, dy = d[move]

    if grid[r + dx][c + dy] == '#':
        continue
    if grid[r + dx][c + dy] == 'O':
        i, j = r + dx, c + dy
        while inb(grid, i, j) and grid[i][j] == 'O':
            i += dx
            j += dy

        if grid[i][j] == '.':
            grid[i][j] = 'O'
            grid[r + dx][c + dy] = '@'
            grid[r][c] = '.'

            r, c = r + dx, c + dy

    else:
        grid[r + dx][c + dy] = '@'
        grid[r][c] = '.'

        r, c = r + dx, c + dy

    print("\n".join(["".join(row) for row in grid]))
    print()

print("\n".join(["".join(row) for row in grid]))
print()
_sum = 0
for i in range(len(grid)):
    for j in range(len(grid[0])):
        if grid[i][j] == 'O':
            _sum += 100 * i + j

print(_sum)
