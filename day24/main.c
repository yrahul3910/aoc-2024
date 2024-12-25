#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SIZE 768

int visited[MAX_SIZE];
char unhash[MAX_SIZE][4];

struct Equation {
    char lhs[4];
    int opcode;
    char rhs[4];
    char result[4];
};

// djb2 hash
unsigned long hash(const char *str) {
    unsigned long hash = 5381;
    int c;

    while ((c = *str++)) {
        hash = (((hash << 5) + hash) + c); /* hash * 33 + c */
    }

    return hash % MAX_SIZE;
}

int and (int a, int b) { return a & b; }

int or (int a, int b) { return a | b; }

int xor (int a, int b) { return a ^ b; }

    int opcode(char *op) {
    if (!strcmp(op, "AND")) {
        return 1;
    } else if (!strcmp(op, "OR")) {
        return 2;
    } else if (!strcmp(op, "XOR")) {
        return 3;
    }

    fprintf(stderr, "Invalid opcode found: %s", op);
    return -1;
}

void visit(int node, int adj[MAX_SIZE][MAX_SIZE], int *visited, int *list,
           size_t *idx) {

    if (strlen(unhash[node]) < 2)
        return;

    if (visited[node]) {
        return;
    }

    visited[node]++;

    // For simplicity, ignore cycles
    for (size_t i = 0; i < MAX_SIZE; i++) {
        if (adj[i][node]) {
            visit(i, adj, visited, list, idx);
        }
    }

    list[(*idx)++] = node;
}

size_t toposort(char nodes[MAX_SIZE][4], size_t nodecount,
                int adj[MAX_SIZE][MAX_SIZE], int *list) {
    size_t idx = 0;

    for (size_t i = 0; i < nodecount; i++) {
        size_t cur_hash = hash(nodes[i]);
        visit(cur_hash, adj, visited, list, &idx);
    }

    return idx;
}

int main() {
    FILE *fp = fopen("input.txt", "r");

    int adj[MAX_SIZE][MAX_SIZE];
    int values[MAX_SIZE];
    struct Equation **equations =
        (struct Equation **)malloc(MAX_SIZE * sizeof(struct Equation *));
    int eq_hash[MAX_SIZE];
    int eq_idx = 0;

    int (*ops[4])(int, int) = {NULL, and, or, xor};

    for (size_t i = 0; i < MAX_SIZE; i++) {
        equations[i] = NULL;
        eq_hash[i] = -1;
        values[i] = -1;
    }

    char buf[20];
    char *cur;
    while (fgets(buf, 20, fp) != NULL && strlen(buf) > 1) {
        cur = strtok(buf, " :\n");
        char *val = strtok(NULL, " :\n");

        size_t cur_hash = hash(cur);
        strcpy(unhash[cur_hash], cur);

        if (values[cur_hash] != -1) {
            fprintf(stderr, "Warning: collision detected: got %d\n",
                    values[cur_hash]);
            exit(1);
        }
        values[cur_hash] = atoi(val);
    }

    // Important: run truncate -s -1 tiny.txt if the input has a newline at the
    // end.
    char nodes[MAX_SIZE][4];
    int idx = 0;

    while (!feof(fp)) {
        fgets(buf, 20, fp);
        char *lhs = strtok(buf, " ->\n");
        char *op = strtok(NULL, " ->\n");
        char *rhs = strtok(NULL, " ->\n");
        char *val = strtok(NULL, " ->\n");

        printf("%s %s %s\n", lhs, rhs, val);

        strcpy(unhash[hash(lhs)], lhs);
        strcpy(unhash[hash(rhs)], rhs);
        strcpy(unhash[hash(val)], val);

        adj[hash(lhs)][hash(val)] = opcode(op);
        adj[hash(rhs)][hash(val)] = opcode(op);

        equations[eq_idx] = (struct Equation *)malloc(sizeof(struct Equation));
        strcpy(equations[eq_idx]->lhs, lhs);
        strcpy(equations[eq_idx]->rhs, rhs);
        strcpy(equations[eq_idx]->result, val);
        equations[eq_idx]->opcode = opcode(op);
        eq_hash[hash(val)] = eq_idx;
        eq_idx++;

        strcpy(nodes[idx++], val);
    }

    int order[MAX_SIZE];
    int count = toposort(nodes, idx, adj, order);

    printf("Topological sort:\n");
    for (size_t i = 0; i < count; i++) {
        printf("%s (%d) --> ", unhash[order[i]], order[i]);
    }

    for (size_t i = 0; i < count; i++) {
        struct Equation *equation = equations[order[i]];

        if (!equation || !*equation->lhs || !*equation->rhs ||
            !*equation->result) {
            continue;
        }

        int lhs = values[hash(equation->lhs)];
        int rhs = values[hash(equation->rhs)];

        if (values[hash(equation->result)] == -1 && lhs != -1 && rhs != -1) {
            values[hash(equation->result)] = ops[equation->opcode](lhs, rhs);
        }
    }

    for (bool loop = true; loop;) {
        bool changed = false;
        for (size_t i = 0; i < eq_idx; i++) {
            struct Equation *equation = equations[i];

            if (values[hash(equation->result)] == -1) {
                int lhs = values[hash(equation->lhs)];
                int rhs = values[hash(equation->rhs)];

                if (lhs == -1 || rhs == -1) {
                    continue;
                }

                values[hash(equation->result)] =
                    ops[equation->opcode](lhs, rhs);
                changed = true;
            }
        }
        loop = changed;
    }

    for (size_t i = 0; i < MAX_SIZE; i++) {
        if (values[i] != -1) {
            printf("%s: %d\n", unhash[i], values[i]);
        } else {
            if (strlen(unhash[i]) > 1) {
                printf("%s: unknown\n", unhash[i]);
            }
        }
    }
}
