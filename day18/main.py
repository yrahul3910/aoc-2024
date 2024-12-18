from collections import deque

GRID_SIZE = 71

lines = open('input.txt', 'r').readlines()
coords = [[int(x) for x in line.split(',')] for line in lines]
print(coords)

def bfs(coords):
    grid = [[0 for _ in range(GRID_SIZE)] for _ in range(GRID_SIZE)]
    grid[0][0] = 1

    q = deque([])
    q.append((0, 0, 0))

    while q:
        x, y, d = q.popleft()

        if (x, y) == (GRID_SIZE - 1, GRID_SIZE - 1):
            return d

        for dx, dy in [(0, 1), (1, 0), (0, -1), (-1, 0)]:
            nx, ny = x + dx, y + dy
            if [nx, ny] in coords:
                continue

            if 0 <= nx < GRID_SIZE and 0 <= ny < GRID_SIZE and grid[nx][ny] == 0:
                q.append((nx, ny, d + 1))
                grid[nx][ny] = 1

def part1():
    KEEP = 1024
    return bfs(coords.copy()[:KEEP])

def part2():
    KEEP = len(coords)
    while not bfs(coords.copy()[:KEEP]):
        KEEP -= 1
    print(coords[KEEP])

print(part1())
part2()
