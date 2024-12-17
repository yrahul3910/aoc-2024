from copy import deepcopy

d = {
    ">": (0, 1),
    "<": (0, -1),
    "^": (-1, 0),
    "v": (1, 0)
}
content = open("input.txt", "r").read()
grid, moves = content.split("\n\n")
moves = moves.replace("\n", "")

def can_move(r, c, move):
    global grid

    dx, dy = d[move]
    
    if all([
        grid[r + dx][c + dy] != '[' or (can_move(r + dx, c + dy + 1, move) and can_move(r + dx, c + dy, move)),
        grid[r + dx][c + dy] != ']' or (can_move(r + dx, c + dy - 1, move) and can_move(r + dx, c + dy, move)),
        grid[r + dx][c + dy] != '#'
        ]):
        grid[r + dx][c + dy], grid[r][c] = grid[r][c], grid[r + dx][c + dy]
        return True
    return False


def part2():
    global grid

    grid = grid.translate(str.maketrans(
            {'#':'##', '.':'..', 'O':'[]', '@':'@.'}))
    grid = [list(row.strip()) for row in grid.split("\n")]
    r = [i for i, row in enumerate(grid) if '@' in row][0]
    c = [j for j, cell in enumerate(grid[r]) if cell == '@'][0]

    for move in moves:
        copy = deepcopy(grid)
        if can_move(r, c, move):
            dx, dy = d[move]
            r += dx
            c += dy
        else:
            grid = copy

    _sum = 0
    for i in range(len(grid)):
        for j in range(len(grid[0])):
            if grid[i][j] == '[':
                _sum += 100 * i + j

    return _sum


def test_part2():
    assert part2() == 1_458_740
