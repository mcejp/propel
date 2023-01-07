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
int is_marked_merged(int);
void mark_merged(int, int);
void dummy_void();
int DIR_LEFT = 0;
void brd_set(int scope2_x, int scope2_y, int scope2_value)
{
    brd_set_with_rotation(scope2_x, scope2_y, DIR_LEFT, scope2_value);
}
int and3(int scope2_a, int scope2_b, int scope2_c)
{
    return builtin_and_ii(builtin_and_ii(scope2_a, scope2_b), scope2_c);
}
int update_column(int scope2_x, int scope2_y, int scope2_dir, int scope2_output_pos)
{
    int scope2_stone = brd_get_with_rotation(scope2_x, scope2_y, scope2_dir);
    int tmp1;
    if (scope2_stone)
    {
        int scope2_should_merge = and3(builtin_greaterthan_ii(scope2_output_pos, 0), builtin_eq_ii(brd_get_with_rotation(builtin_sub_ii(scope2_output_pos, 1), scope2_y, scope2_dir), scope2_stone), builtin_not_i(is_marked_merged(builtin_sub_ii(scope2_output_pos, 1))));
        int tmp0;
        if (scope2_should_merge)
        {
            brd_set_with_rotation(builtin_sub_ii(scope2_output_pos, 1), scope2_y, scope2_dir, builtin_mul_ii(2, scope2_stone));
            mark_merged(builtin_sub_ii(scope2_output_pos, 1), 1);
            tmp0 = scope2_output_pos;
        }
        else
        {
            brd_set_with_rotation(scope2_output_pos, scope2_y, scope2_dir, scope2_stone);
            mark_merged(scope2_output_pos, 0);
            tmp0 = builtin_add_ii(scope2_output_pos, 1);
        }
        tmp1 = tmp0;
    }
    else
    {
        tmp1 = scope2_output_pos;
    }
    return tmp1;
}
void update_row(int scope2_y, int scope2_dir)
{
    int scope2_output_pos = 0;
    scope2_output_pos = update_column(0, scope2_y, scope2_dir, scope2_output_pos);;
    scope2_output_pos = update_column(1, scope2_y, scope2_dir, scope2_output_pos);;
    scope2_output_pos = update_column(2, scope2_y, scope2_dir, scope2_output_pos);;
    scope2_output_pos = update_column(3, scope2_y, scope2_dir, scope2_output_pos);;
    if (builtin_lessthan_ii(scope2_output_pos, 1))
    {
        brd_set_with_rotation(0, scope2_y, scope2_dir, 0);
    }
    else
    {
        dummy_void();
    }
    if (builtin_lessthan_ii(scope2_output_pos, 2))
    {
        brd_set_with_rotation(1, scope2_y, scope2_dir, 0);
    }
    else
    {
        dummy_void();
    }
    if (builtin_lessthan_ii(scope2_output_pos, 3))
    {
        brd_set_with_rotation(2, scope2_y, scope2_dir, 0);
    }
    else
    {
        dummy_void();
    }
    if (builtin_lessthan_ii(scope2_output_pos, 4))
    {
        brd_set_with_rotation(3, scope2_y, scope2_dir, 0);
    }
    else
    {
        dummy_void();
    }
}
void generate_new_stone()
{
    int tmp2;
    if (builtin_lessthan_ii(random_int(0, 100), 90))
    {
        tmp2 = 2;
    }
    else
    {
        tmp2 = 4;
    }
    int scope2_new_stone_value = tmp2;
    int scope2_num_empty_spots = brd_count_empty_spots();
    int scope2_nth_spot = random_int(0, scope2_num_empty_spots);
    int scope2_x = brd_get_nth_empty_slot_x(scope2_nth_spot);
    int scope2_y = brd_get_nth_empty_slot_y(scope2_nth_spot);
    brd_set(scope2_x, scope2_y, scope2_new_stone_value);
}
void make_turn(int scope2_dir)
{
    update_row(0, scope2_dir);
    update_row(1, scope2_dir);
    update_row(2, scope2_dir);
    update_row(3, scope2_dir);
}
