lines = open('input.txt', 'r').readlines()
lines = [line.split(" ") for line in lines]
lines = [[int(y) for y in x] for x in lines]

count = 0
for line in lines:
    if sorted(line) == line or sorted(line, reverse=True) == line:
        if all([1 <= abs(y - x) <= 3 for x, y in zip(line[:-1], line[1:])]):
            count += 1
            continue

    # Try all removals
    for i in range(len(line)):
        new_line = line[:i] + line[i+1:]
        if sorted(new_line) == new_line or sorted(new_line, reverse=True) == new_line:
            if all([1 <= abs(y - x) <= 3 for x, y in zip(new_line[:-1], new_line[1:])]):
                count += 1
                break

print(count)
