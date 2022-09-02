inline int builtin_eq_ii(int a, int b) { return a == b; }
inline int builtin_add_ii(int a, int b) { return a + b; }
inline int builtin_sub_ii(int a, int b) { return a - b; }
inline int builtin_mul_ii(int a, int b) { return a * b; }
inline int builtin_lessthan_ii(int a, int b) { return (a < b) ? 1 : 0; }
inline int builtin_greaterthan_ii(int a, int b) { return (a > b) ? 1 : 0; }
inline int builtin_and_ii(int a, int b) { return a && b; }
inline int builtin_not_i(int a) { return a ? 0 : 1; }

int get_player_input();
auto scope2_get_player_input = get_player_input;
;
int random_int(int, int);
auto scope2_random_int = random_int;
;
int brd_count_empty_spots();
auto scope2_brd_count_empty_spots = brd_count_empty_spots;
;
int brd_get_nth_empty_slot_x(int);
auto scope2_brd_get_nth_empty_slot_x = brd_get_nth_empty_slot_x;
;
int brd_get_nth_empty_slot_y(int);
auto scope2_brd_get_nth_empty_slot_y = brd_get_nth_empty_slot_y;
;
int brd_get_with_rotation(int, int, int);
auto scope2_brd_get_with_rotation = brd_get_with_rotation;
;
void brd_set_with_rotation(int, int, int, int);
auto scope2_brd_set_with_rotation = brd_set_with_rotation;
;
int is_marked_merged(int);
auto scope2_is_marked_merged = is_marked_merged;
;
void mark_merged(int, int);
auto scope2_mark_merged = mark_merged;
;
void dummy_void();
auto scope2_dummy_void = dummy_void;
;
int scope2_DIR_LEFT = 0;
;
void scope2_brd_set(int scope3_x, int scope3_y, int scope3_value)
{
    scope2_brd_set_with_rotation(scope3_x, scope3_y, scope2_DIR_LEFT, scope3_value);
}
;
int scope2_and3(int scope3_a, int scope3_b, int scope3_c)
{
    return builtin_and_ii(builtin_and_ii(scope3_a, scope3_b), scope3_c);
}
;
int scope2_update_column(int scope3_x, int scope3_y, int scope3_dir, int scope3_output_pos)
{
    int scope4_stone = scope2_brd_get_with_rotation(scope3_x, scope3_y, scope3_dir);
    ;
    int tmp1;
    if (scope4_stone)
    {
        int scope5_should_merge = scope2_and3(builtin_greaterthan_ii(scope3_output_pos, 0), builtin_eq_ii(scope2_brd_get_with_rotation(builtin_sub_ii(scope3_output_pos, 1), scope3_y, scope3_dir), scope4_stone), builtin_not_i(scope2_is_marked_merged(builtin_sub_ii(scope3_output_pos, 1))));
        ;
        int tmp0;
        if (scope5_should_merge)
        {
            scope2_brd_set_with_rotation(builtin_sub_ii(scope3_output_pos, 1), scope3_y, scope3_dir, builtin_mul_ii(2, scope4_stone));
            scope2_mark_merged(builtin_sub_ii(scope3_output_pos, 1), 1);
            tmp0 = scope3_output_pos;
        }
        else
        {
            scope2_brd_set_with_rotation(scope3_output_pos, scope3_y, scope3_dir, scope4_stone);
            scope2_mark_merged(scope3_output_pos, 0);
            tmp0 = builtin_add_ii(scope3_output_pos, 1);
        }
        tmp1 = tmp0;
    }
    else
    {
        tmp1 = scope3_output_pos;
    }
    return tmp1;
}
;
void scope2_update_row(int scope3_y, int scope3_dir)
{
    int scope4_output_pos = 0;
    ;
    scope4_output_pos = scope2_update_column(0, scope3_y, scope3_dir, scope4_output_pos);;
    scope4_output_pos = scope2_update_column(1, scope3_y, scope3_dir, scope4_output_pos);;
    scope4_output_pos = scope2_update_column(2, scope3_y, scope3_dir, scope4_output_pos);;
    scope4_output_pos = scope2_update_column(3, scope3_y, scope3_dir, scope4_output_pos);;
    if (builtin_lessthan_ii(scope4_output_pos, 1))
    {
        scope2_brd_set_with_rotation(0, scope3_y, scope3_dir, 0);
    }
    else
    {
        scope2_dummy_void();
    }
    ;
    if (builtin_lessthan_ii(scope4_output_pos, 2))
    {
        scope2_brd_set_with_rotation(1, scope3_y, scope3_dir, 0);
    }
    else
    {
        scope2_dummy_void();
    }
    ;
    if (builtin_lessthan_ii(scope4_output_pos, 3))
    {
        scope2_brd_set_with_rotation(2, scope3_y, scope3_dir, 0);
    }
    else
    {
        scope2_dummy_void();
    }
    ;
    if (builtin_lessthan_ii(scope4_output_pos, 4))
    {
        scope2_brd_set_with_rotation(3, scope3_y, scope3_dir, 0);
    }
    else
    {
        scope2_dummy_void();
    }
    ;
}
;
void scope2_do_turn()
{
    int tmp2;
    if (builtin_lessthan_ii(scope2_random_int(0, 100), 90))
    {
        tmp2 = 2;
    }
    else
    {
        tmp2 = 4;
    }
    int scope4_new_stone_value = tmp2;
    ;
    int scope4_num_empty_spots = scope2_brd_count_empty_spots();
    ;
    int scope4_nth_spot = scope2_random_int(0, scope4_num_empty_spots);
    ;
    int scope4_x = scope2_brd_get_nth_empty_slot_x(scope4_nth_spot);
    ;
    int scope4_y = scope2_brd_get_nth_empty_slot_y(scope4_nth_spot);
    ;
    int scope4_dir = scope2_get_player_input();
    ;
    scope2_update_row(0, scope4_dir);
    scope2_update_row(1, scope4_dir);
    scope2_update_row(2, scope4_dir);
    scope2_update_row(3, scope4_dir);
}
