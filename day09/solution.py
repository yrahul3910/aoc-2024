def p1(inp: str):
    inp_len = len(inp)

    i = 0  # Left idx
    j = inp_len - 1  # Right idx
    cur_left_file_ct = int(inp[i])
    cur_left_file_id = 0
    is_empty = False  # Is this an empty block?
    cur_right_file_ct = int(inp[j])
    cur_right_file_id = len(inp) // 2

    _sum = 0
    k = 0  # Block number
    while i < j:
        if is_empty:
            while cur_left_file_ct > 0 and cur_right_file_ct > 0:
                _sum += cur_right_file_id * k
                cur_left_file_ct -= 1
                cur_right_file_ct -= 1
                k += 1

                if cur_right_file_ct == 0:
                    j -= 2
                    cur_right_file_ct = int(inp[j])
                    cur_right_file_id -= 1
        else:
            while cur_left_file_ct > 0:
                _sum += cur_left_file_id * k
                cur_left_file_ct -= 1
                k += 1

            cur_left_file_id += 1

        is_empty = not is_empty
        i += 1
        cur_left_file_ct = int(inp[i])

    if i == j:
        cur_left_file_ct = min(cur_left_file_ct, cur_right_file_ct)
        while cur_left_file_ct > 0:
            _sum += k * cur_left_file_id
            cur_left_file_ct -= 1
            k += 1

    return _sum


def p2(inp: str):
    inp_len = len(inp)
    orig_inp = [int(c) for c in inp[:]]
    print(f"{inp_len = }")

    i = 0  # Left idx
    _sum = 0
    k = 0  # Block number

    while i < inp_len:
        if inp[i] == "X":
            i += 1
            continue

        # Loop invariant: k is always the sum up to i.
        k = sum(orig_inp[:i])

        if i % 2 == 0:
            for _ in range(int(inp[i])):
                cur_left_file_id = i // 2
                _sum += cur_left_file_id * k
                print(f"{cur_left_file_id} * {k}")
                k += 1
        else:
            for j in range(inp_len - 1, i, -2):
                if inp[j] == "X":
                    continue

                cur_left_file_ct = int(inp[i])
                cur_right_file_ct = int(inp[j])

                if cur_left_file_ct >= cur_right_file_ct:
                    for _ in range(cur_right_file_ct):
                        cur_right_file_id = j // 2
                        _sum += cur_right_file_id * k
                        print(f"{cur_right_file_id} * {k}")
                        k += 1

                    inp = inp[:i] + f"{cur_left_file_ct - cur_right_file_ct}" + inp[i+1:j] + "X" + inp[j+1:]

        i += 1

    return _sum


def test_part1():
    assert (r := p1("2333133121414131402")) == 1928, r
    assert (r := p1(open("input.txt", "r").read().strip())) == 6360094256423, r


def test_part2():
    assert (r := p2("2333133121414131402")) == 2858, r
    assert (r := p2(open("input.txt", "r").read().strip())) == 6379677752410, r
