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
    print(f"{inp_len = }")

    i = 0  # Left idx
    j = inp_len - 1  # Right idx
    cur_left_file_ct = int(inp[i])
    cur_left_file_id = 0
    is_empty = False  # Is this an empty block?
    cur_right_file_ct = int(inp[j])
    cur_right_file_id = len(inp) // 2

    _sum = 0
    k = 0  # Block number
    rem_files = []
    files_done = []

    while i < j:
        if is_empty:
            _i = i
            _j = inp_len - 1
            changed = False
            while _i < _j:
                # Find a right file that can fit
                while (cur_left_file_ct < cur_right_file_ct and _i < _j) or (_j in files_done):
                    _j -= 2
                    cur_right_file_ct = int(inp[_j])

                if _i >= _j:
                    rem_files.append(j)
                else:
                    files_done.append(_j)
                    if _j in rem_files:
                        rem_files.remove(_j)

                cur_right_file_id = _j // 2
                while cur_left_file_ct >= cur_right_file_ct and min(cur_left_file_ct, cur_right_file_ct) > 0 and _i < _j:
                    _sum += cur_right_file_id * k
                    print(f"[M] {cur_right_file_id} * {k}")
                    cur_left_file_ct -= 1
                    cur_right_file_ct -= 1
                    k += 1
                    changed = True

                _j -= 2
                cur_right_file_ct = int(inp[_j])
                cur_right_file_id -= 1

            if cur_left_file_ct > 0 and changed:
                is_empty = True
            else:
                is_empty = False
                i += 1
                cur_left_file_ct = int(inp[i])
        else:
            while i in files_done and i < j:
                i += 2

            cur_left_file_ct = int(inp[i])
            cur_left_file_id = i // 2
            print(f"{i = }, {cur_left_file_id = }, {cur_left_file_ct = }, {files_done = }")
            while cur_left_file_ct > 0:
                _sum += cur_left_file_id * k
                print(f"[L] {cur_left_file_id} * {k}")
                cur_left_file_ct -= 1
                k += 1

            cur_left_file_id += 1
            is_empty = True
            files_done.append(i)

            i += 1
            cur_left_file_ct = int(inp[i])

    while i < len(inp):
        if i in rem_files:
            cur_left_file_ct = int(inp[i])

            while cur_left_file_ct > 0:
                _sum += k * cur_left_file_id
                print(f"{cur_left_file_id} * {k}")
                cur_left_file_ct -= 1
                k += 1

        i += 1
        k += 1

    return _sum


assert (r := p1("2333133121414131402")) == 1928, r
assert (r := p1(open("input.txt", "r").read().strip())) == 6360094256423, r
print("P1 passed")

assert (r := p2("2333133121414131402")) == 2858, r
