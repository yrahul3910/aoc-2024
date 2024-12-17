import sys


def inb(grid, i, j):
    return i >= 0 and i < len(grid) and j >= 0 and j < len(grid[0])


content = open(sys.argv[-1]).read()
grid, moves = content.split("\n\n")
moves = moves.replace("\n", "")

r = [i for i, row in enumerate(grid) if '@' in row][0]
c = [j for j, cell in enumerate(grid[r]) if cell == '@'][0]
d = {
    ">": (0, 1),
    "<": (0, -1),
    "^": (-1, 0),
    "v": (1, 0)
}

def get(grid, r, c):
    if inb(grid, r, c):
        return grid[r][c]
    return '#'

def can_move(r, c, move):
    global grid

    dx, dy = d[move]
    
    if all([
        get(grid, r + dx, c + dy) != '[' or (can_move(r + dx, c + dy + 1, move) and can_move(r + dx, c + dy, move)),
        get(grid, r + dx, c + dy) != ']' or (can_move(r + dx, c + dy - 1, move) and can_move(r + dx, c + dy, move)),
        get(grid, r + dx, c + dy) != '#'
        ]):
        grid[r + dx][c + dy], grid[r][c] = grid[r][c], grid[r + dx][c + dy]
        return True
    return False


grid = grid.translate(str.maketrans(
        {'#':'##', '.':'..', 'O':'[]', '@':'@.'}))
grid = [list(row.strip()) for row in grid.split("\n")]

for move in moves:
    if can_move(r, c, move):
        dx, dy = d[move]
        r += dx
        c += dy

_sum = 0
for i in range(len(grid)):
    for j in range(len(grid[0])):
        if grid[i][j] == '[':
            _sum += 100 * i + j

print(_sum)
