class UnionFind:
    def __init__(self, n: int) -> None:
        self.n = n
        self.parents = [None] * n
        self.ranks = [1] * n
        self.num_sets = n
    
    def find(self, i: int) -> int:
        p = self.parents[i]
        if p is None:
            return i
        p = self.find(p)
        self.parents[i] = p
        return p

    def finalize(self):
        sets = {(k := self.find(i) or i): set([k]) for i in range(self.n)}
        for i in range(self.n):
            if (p:= self.find(i)) in sets:
                sets[p].add(i)
            else:
                sets[p] = set([p])
        dsus = list(sets.values())
        
        ret = []

        for s in dsus:
            if None in s or (len(s) == 1 and any(list(s)[0] in t for t in dsus if len(t) > 1)):
                continue
            ret.append(s)
        return ret
    
    def in_same_set(self, i: int, j: int) -> bool:
        return self.find(i) == self.find(j)
    
    def merge(self, i: int, j: int) -> None:
        i = self.find(i)
        j = self.find(j)

        if i == j:
            return
        
        i_rank = self.ranks[i]
        j_rank = self.ranks[j]

        if i_rank < j_rank:
            self.parents[i] = j
        elif i_rank > j_rank:
            self.parents[j] = i
        else:
            self.parents[j] = i
            self.ranks[i] += 1
        self.num_sets -= 1
