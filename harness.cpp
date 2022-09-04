#include <stdexcept>
#include <cstdio>
#include <cstdlib>

int random_int(int min, int max_excl) {
    return min + (rand() % (max_excl - min));
}

int board[4][4];

int brd_count_empty_spots() {
    int empty = 0;

    for (int y = 0; y < 4; y++) {
        for (int x = 0; x < 4; x++) {
            if (!board[y][x]) {
                empty++;
            }
        }
    }

    return empty;
}

int brd_get_nth_empty_slot_x(int nth) {
    for (int y = 0; y < 4; y++) {
        for (int x = 0; x < 4; x++) {
            if (!board[y][x]) {
                if (nth-- == 0) {
                    return x;
                }
            }
        }
    }

    throw std::runtime_error("brd_get_nth_empty_slot");
}

int brd_get_nth_empty_slot_y(int nth) {
    for (int y = 0; y < 4; y++) {
        for (int x = 0; x < 4; x++) {
            if (!board[y][x]) {
                if (nth-- == 0) {
                    return y;
                }
            }
        }
    }

    throw std::runtime_error("brd_get_nth_empty_slot");
}

int get_player_input() {
    return 0;
}

int brd_get_with_rotation(int x, int y, int rot) {
    if (rot != 0)
        throw std::runtime_error("brd_get_with_rotation");
    return board[y][x];
}

void brd_set_with_rotation(int x, int y, int rot, int value) {
    if (rot != 0)
        throw std::runtime_error("brd_set_with_rotation");
    board[y][x] = value;
}

// instead of this array it should be sufficient to track whether *last output* was merged or not
int merged[4];

int is_marked_merged(int pos) {
    return merged[pos];
}

void mark_merged(int pos, int value) {
    merged[pos] = value;
}

void dummy_void() {}

void display_board() {
    for (int y = 0; y < 4; y++) {
        for (int x = 0; x < 4; x++) {
            if (!board[y][x]) {
                printf(".");
            }
            else {
                printf("%d", board[y][x]);
            }
        }
        printf("\n");
    }
    printf("\n");
}

void generate_board() {
    for (int y = 0; y < 4; y++) {
        for (int x = 0; x < 4; x++) {
            if (rand() % 10 < 3) {
                board[y][x] = 2;
            }
        }
    }
}

void scope2_make_turn(int scope3_dir);

int main() {
    display_board();
    generate_board();
    display_board();
    scope2_make_turn(0);
    display_board();
}
