from collections import deque
import itertools

grid = open('input.txt').read().splitlines()
m = len(grid)
n = len(grid[0])

start_row = [i for i, row in enumerate(grid) if 'S' in row][0]
start_col = grid[start_row].index('S')

def bfs(max_dist):
    visited = [[0 for _ in range(n)] for _ in range(m)]
    visited[start_row][start_col] = 1

    q = deque([])
    q.append((start_row, start_col, 0))
    dist = {(start_row, start_col): 0}

    while q:
        x, y, d = q.popleft()

        if grid[x][y] == 'E':
            break

        for dx, dy in [(0, 1), (1, 0), (0, -1), (-1, 0)]:
            nx, ny = x + dx, y + dy

            if 0 <= nx < m and 0 <= ny < n and visited[nx][ny] == 0 and grid[nx][ny] != '#':
                q.append((nx, ny, d + 1))
                dist[(nx, ny)] = d + 1
                visited[nx][ny] = 1

    count = 0
    for (x1, y1), (x2, y2) in itertools.combinations(dist.keys(), 2):
        if 1 < abs(x1 - x2) + abs(y1 - y2) <= max_dist:
                if abs(dist[(x1, y1)] - dist[(x2, y2)]) >= 100 + abs(x1 - x2) + abs(y1 - y2):
                    count += 1

    return count

def part1():
    return bfs(2)

def part2():
    return bfs(20)

def test_part1():
    assert part1() == 1346

def test_part2():
    assert part2() == 985482
