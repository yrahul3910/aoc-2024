#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SIZE 768
#define VAR_LENGTH 4
#define BUFSIZE 20

struct Equation {
    char lhs[VAR_LENGTH];
    int opcode;
    char rhs[VAR_LENGTH];
    char result[VAR_LENGTH];
};

// Global to avoid stack overflow with large arrays
// and maintain consistency across recursive calls
int visited[MAX_SIZE];
char unhash[MAX_SIZE][VAR_LENGTH];

/**
 * Computes a hash value for a string using the djb2 algorithm.
 * Collision handling: Currently exits on collision.
 * @param str Input string
 * @return Hash value modulo MAX_SIZE
 */
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

/**
 * Visit a node in a DFS fashion.
 * @param node The node to visit
 * @param adj Adjacency matrix
 * @param visited Visited nodes tracking
 * @param unhash Hash to node name mapping
 * @param list Output sorted list
 */
void visit(int node, int adj[MAX_SIZE][MAX_SIZE], int *list, size_t *idx) {
    if (strlen(unhash[node]) < 2)
        return;

    if (visited[node]) {
        return;
    }

    visited[node]++;

    // For simplicity, ignore cycles
    for (size_t i = 0; i < MAX_SIZE; i++) {
        if (adj[i][node]) {
            visit(i, adj, list, idx);
        }
    }

    list[(*idx)++] = node;
}

/**
 * Performs topological sort on the graph.
 * @param nodes Array of node names
 * @param nodecount Number of nodes
 * @param adj Adjacency matrix
 * @param list Output sorted list
 * @return Number of nodes in sorted order
 */
size_t toposort(char nodes[MAX_SIZE][VAR_LENGTH], size_t nodecount,
                int adj[MAX_SIZE][MAX_SIZE], int *list) {
    size_t idx = 0;

    for (size_t i = 0; i < nodecount; i++) {
        size_t cur_hash = hash(nodes[i]);
        visit(cur_hash, adj, list, &idx);
    }

    return idx;
}

/**
 * Cleanup allocated resources and exit.
 * @param equations Array of equation pointers to free
 * @param eq_size Number of equations
 * @param fp File pointer to close
 */
void cleanup(struct Equation **equations, size_t eq_size, FILE *fp) {
    for (size_t i = 0; i < eq_size; i++) {
        free(equations[i]);
    }

    free(equations);
    fclose(fp);
    exit(1);
}

int main() {
    FILE *fp = fopen("medium.txt", "r");

    if (!fp) {
        fprintf(stderr, "Could not open file.\n");
        exit(1);
    }

    int adj[MAX_SIZE][MAX_SIZE] = {0};
    int values[MAX_SIZE];
    struct Equation **equations = malloc(MAX_SIZE * sizeof(struct Equation *));

    if (equations == NULL) {
        fprintf(stderr, "Could not allocate memory.\n");
        exit(1);
    }

    int eq_hash[MAX_SIZE];
    int eq_idx = 0;

    int (*ops[4])(int, int) = {NULL, and, or, xor};

    for (size_t i = 0; i < MAX_SIZE; i++) {
        equations[i] = NULL;
        eq_hash[i] = -1;
        values[i] = -1;
    }

    char buf[BUFSIZE];
    char *cur;
    while (fgets(buf, BUFSIZE, fp) != NULL && strlen(buf) > 1) {
        cur = strtok(buf, " :\n");
        char *val = strtok(NULL, " :\n");

        size_t cur_hash = hash(cur);
        snprintf(unhash[cur_hash], VAR_LENGTH, "%s", cur);

        if (values[cur_hash] != -1) {
            fprintf(stderr, "Warning: collision detected: got %d\n",
                    values[cur_hash]);
            cleanup(equations, eq_idx, fp);
        }
        values[cur_hash] = atoi(val);
    }

    // Important: run truncate -s -1 tiny.txt if the input has a newline at the
    // end.
    char nodes[MAX_SIZE][VAR_LENGTH];
    int idx = 0;

    while (fgets(buf, BUFSIZE, fp) != NULL) {
        char *lhs = strtok(buf, " ->\n");
        char *op = strtok(NULL, " ->\n");
        char *rhs = strtok(NULL, " ->\n");
        char *val = strtok(NULL, " ->\n");

        if (!lhs || !op || !rhs || !val) {
            fprintf(stderr, "Warning: parsing %s had errors.\n", buf);
            cleanup(equations, eq_idx, fp);
        }

        snprintf(unhash[hash(lhs)], VAR_LENGTH, "%s", lhs);
        snprintf(unhash[hash(rhs)], VAR_LENGTH, "%s", rhs);
        snprintf(unhash[hash(val)], VAR_LENGTH, "%s", val);

        adj[hash(lhs)][hash(val)] = opcode(op);
        adj[hash(rhs)][hash(val)] = opcode(op);

        equations[eq_idx] = (struct Equation *)malloc(sizeof(struct Equation));
        if (!equations[eq_idx]) {
            fprintf(stderr, "Memory allocation failed\n");
            cleanup(equations, eq_idx, fp);
        }

        snprintf(equations[eq_idx]->lhs, VAR_LENGTH, "%s", lhs);
        snprintf(equations[eq_idx]->rhs, VAR_LENGTH, "%s", rhs);
        snprintf(equations[eq_idx]->result, VAR_LENGTH, "%s", val);
        equations[eq_idx]->opcode = opcode(op);
        eq_hash[hash(val)] = eq_idx;
        eq_idx++;

        snprintf(nodes[idx++], VAR_LENGTH, "%s", val);
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

    cleanup(equations, eq_idx, fp);
}
