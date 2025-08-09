#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SIZE 768
#define VAR_LENGTH 4
#define BUFSIZE 20

struct Equation {
    char lhs[VAR_LENGTH];
    char op[VAR_LENGTH];
    char rhs[VAR_LENGTH];
    char result[VAR_LENGTH];
    int opcode;
};

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
    FILE *fp = fopen("input.txt", "r");

    if (!fp) {
        fprintf(stderr, "Could not open file.\n");
        exit(1);
    }

    int values[MAX_SIZE];
    struct Equation** equations = (struct Equation**) malloc(MAX_SIZE * sizeof(struct Equation*));

    if (equations == NULL) {
        fprintf(stderr, "Failed to allocate memory.");
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

        if (values[cur_hash] != -1) {
            fprintf(stderr, "Warning: collision detected: got %d\n",
                    values[cur_hash]);
            cleanup(equations, eq_idx, fp);
        }
        values[cur_hash] = val[0] - '0';
    }

    while (fgets(buf, BUFSIZE, fp) != NULL) {
        char *lhs = strtok(buf, " ->\n");
        char *op = strtok(NULL, " ->\n");
        char *rhs = strtok(NULL, " ->\n");
        char *val = strtok(NULL, " ->\n");

        printf("%s %s %s %s\n", lhs, op, rhs, val);

        if (!lhs || !op || !rhs || !val) {
            fprintf(stderr, "Warning: parsing %s had errors.\n", buf);
            cleanup(equations, eq_idx, fp);
        }

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
    }

    for (bool cont = true; cont;) {
        bool changed = false;
        for (size_t i = 0; i < eq_idx; i++) {
            struct Equation *equation = equations[i];

            if (values[hash(equation->result)] == -1) {
                int lhs = values[hash(equation->lhs)];
                int rhs = values[hash(equation->rhs)];

                if (lhs == -1 || rhs == -1) {
                    continue;
                }
                changed = true;

                values[hash(equation->result)] =
                    ops[equation->opcode](lhs, rhs);
            }
        }
        cont = changed;
    }

    unsigned long long sum = 0;
    for (int i = 0; i < 46; i++) {
        char var[4];
        snprintf(var, VAR_LENGTH, "z%02d", i);

        sum += (unsigned long long)values[hash(var)] << i;
    }
    printf("\n%llu\n", sum);

    cleanup(equations, eq_idx, fp);
}
