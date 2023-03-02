int get_player_input();
int random_int(int, int);
int brd_count_empty_spots();
int brd_get_nth_empty_slot_x(int);
int brd_get_nth_empty_slot_y(int);
int brd_get_with_rotation(int, int, int);
void brd_set_with_rotation(int, int, int, int);
const int DIR_LEFT = 0;
void brd_set(int x_8, int y_8, int value_8)
{
    brd_set_with_rotation(x_8, y_8, DIR_LEFT, value_8);
}
int and3(int a_9, int b_9, int c_9)
{
    return ((a_9 && b_9) && c_9);
}
void update_row(int y_10, int dir_10)
{
    int output_pos_10 = 0;
    int was_merged_10 = 0;
    int x_10 = 0;
    while ((x_10 < 4))
    {
        const int stone_10 = brd_get_with_rotation(x_10, y_10, dir_10);
        if (stone_10)
        {
            const int should_merge_10 = and3((output_pos_10 > 0), (brd_get_with_rotation((output_pos_10 - 1), y_10, dir_10) == stone_10), (!was_merged_10));
            if (should_merge_10)
            {
                brd_set_with_rotation((output_pos_10 - 1), y_10, dir_10, (2 * stone_10));
                was_merged_10 = 1;
                ;
            }
            else
            {
                brd_set_with_rotation(output_pos_10, y_10, dir_10, stone_10);
                was_merged_10 = 0;
                output_pos_10 = (output_pos_10 + 1);
                ;
            }
            ;
        }
        else
        {
            ;
        }
        x_10 = (x_10 + 1);
        ;
    }
    int columnn_10 = 0;
    while ((columnn_10 < 4))
    {
        if ((output_pos_10 <= columnn_10))
        {
            brd_set_with_rotation(columnn_10, y_10, dir_10, 0);
        }
        else
        {
            ;
        }
        columnn_10 = (columnn_10 + 1);
        ;
    }
}
void generate_new_stone()
{
    const int new_stone_value_11 = ((random_int(0, 100) < 90)) ? (2) : (4);
    const int num_empty_spots_11 = brd_count_empty_spots();
    const int nth_spot_11 = random_int(0, num_empty_spots_11);
    const int x_11 = brd_get_nth_empty_slot_x(nth_spot_11);
    const int y_11 = brd_get_nth_empty_slot_y(nth_spot_11);
    brd_set(x_11, y_11, new_stone_value_11);
}
void make_turn(int dir_12)
{
    int row_12 = 0;
    while ((row_12 < 4))
    {
        update_row(row_12, dir_12);
        row_12 = (row_12 + 1);
        ;
    }
}
