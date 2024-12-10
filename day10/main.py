def get_input(filename: str):
    lines = open(filename, 'r').readlines()
    grid = [list(line.strip()) for line in lines]
    grid = [[int(cell) for cell in row] for row in grid]

    return grid


def in_bounds(grid, x, y):
    return x >= 0 and x < len(grid) and y >= 0 and y < len(grid[0])


def dfs(grid, visited, score, x, y, stop_on_visited=True):
    if visited[x][y] and stop_on_visited:
        return score

    visited[x][y] = 1

    if grid[x][y] == 9:
        return score + 1

    if in_bounds(grid, x+1, y) and grid[x+1][y] - grid[x][y] == 1:
        score = dfs(grid, visited, score, x+1, y, stop_on_visited)
    if in_bounds(grid, x-1, y) and grid[x-1][y] - grid[x][y] == 1:
        score = dfs(grid, visited, score, x-1, y, stop_on_visited)
    if in_bounds(grid, x, y+1) and grid[x][y+1] - grid[x][y] == 1:
        score = dfs(grid, visited, score, x, y+1, stop_on_visited)
    if in_bounds(grid, x, y-1) and grid[x][y-1] - grid[x][y] == 1:
        score = dfs(grid, visited, score, x, y-1, stop_on_visited)
    
    return score


def all_zeros(grid):
    for i in range(len(grid)):
        for j in range(len(grid[0])):
            if grid[i][j] == 0:
                yield i, j


def part1(filename: str):
    grid = get_input(filename)
    score = 0
    for i, j in all_zeros(grid):
        visited = [[0 for _ in range(len(grid[0]))] for _ in range(len(grid))]
        score += dfs(grid, visited, 0, i, j)

    return score


def part2(filename: str):
    grid = get_input(filename)
    score = 0
    for i, j in all_zeros(grid):
        visited = [[0 for _ in range(len(grid[0]))] for _ in range(len(grid))]
        score += dfs(grid, visited, 0, i, j, False)

    return score


assert (r := part1('tiny.txt')) == 36, r
assert (r := part1('input.txt')) == 778, r
print('Part 1: PASS')

assert (r := part2('tiny.txt')) == 81, r
assert (r := part2('input.txt')) == 1925, r
print('Part 2: PASS')
