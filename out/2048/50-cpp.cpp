inline int builtin_eq_ii(int a, int b) { return a == b; }
inline int builtin_add_ii(int a, int b) { return a + b; }
inline int builtin_sub_ii(int a, int b) { return a - b; }
inline int builtin_mul_ii(int a, int b) { return a * b; }
inline int builtin_lessthan_ii(int a, int b) { return (a < b) ? 1 : 0; }
inline int builtin_lesseq_ii(int a, int b) { return (a <= b) ? 1 : 0; }
inline int builtin_greaterthan_ii(int a, int b) { return (a > b) ? 1 : 0; }
inline int builtin_and_ii(int a, int b) { return a && b; }
inline int builtin_not_i(int a) { return a ? 0 : 1; }

int get_player_input();
int random_int(int, int);
int brd_count_empty_spots();
int brd_get_nth_empty_slot_x(int);
int brd_get_nth_empty_slot_y(int);
int brd_get_with_rotation(int, int, int);
void brd_set_with_rotation(int, int, int, int);
int DIR_LEFT = 0;
void brd_set(int x_8, int y_8, int value_8)
{
    brd_set_with_rotation(x_8, y_8, DIR_LEFT, value_8);
}
int and3(int a_9, int b_9, int c_9)
{
    return builtin_and_ii(builtin_and_ii(a_9, b_9), c_9);
}
void update_row(int y_10, int dir_10)
{
    int output_pos_10 = 0;
    int was_merged_10 = 0;
    int x_10 = 0;
    while (builtin_lessthan_ii(x_10, 4))
    {
        int stone_10 = brd_get_with_rotation(x_10, y_10, dir_10);
        if (stone_10)
        {
            int should_merge_10 = and3(builtin_greaterthan_ii(output_pos_10, 0), builtin_eq_ii(brd_get_with_rotation(builtin_sub_ii(output_pos_10, 1), y_10, dir_10), stone_10), builtin_not_i(was_merged_10));
            if (should_merge_10)
            {
                brd_set_with_rotation(builtin_sub_ii(output_pos_10, 1), y_10, dir_10, builtin_mul_ii(2, stone_10));
                was_merged_10 = 1;;
            }
            else
            {
                brd_set_with_rotation(output_pos_10, y_10, dir_10, stone_10);
                was_merged_10 = 0;;
                output_pos_10 = builtin_add_ii(output_pos_10, 1);;
            }
            ;
        }
        else
        {
            ;
        }
        x_10 = builtin_add_ii(x_10, 1);;
    }
    int columnn_10 = 0;
    while (builtin_lessthan_ii(columnn_10, 4))
    {
        if (builtin_lesseq_ii(output_pos_10, columnn_10))
        {
            brd_set_with_rotation(columnn_10, y_10, dir_10, 0);
        }
        else
        {
            ;
        }
        columnn_10 = builtin_add_ii(columnn_10, 1);;
    }
}
void generate_new_stone()
{
    int tmp0;
    if (builtin_lessthan_ii(random_int(0, 100), 90))
    {
        tmp0 = 2;
    }
    else
    {
        tmp0 = 4;
    }
    int new_stone_value_11 = tmp0;
    int num_empty_spots_11 = brd_count_empty_spots();
    int nth_spot_11 = random_int(0, num_empty_spots_11);
    int x_11 = brd_get_nth_empty_slot_x(nth_spot_11);
    int y_11 = brd_get_nth_empty_slot_y(nth_spot_11);
    brd_set(x_11, y_11, new_stone_value_11);
}
void make_turn(int dir_12)
{
    int row_12 = 0;
    while (builtin_lessthan_ii(row_12, 4))
    {
        update_row(row_12, dir_12);
        row_12 = builtin_add_ii(row_12, 1);;
    }
}
