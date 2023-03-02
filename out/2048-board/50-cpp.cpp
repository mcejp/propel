int board[] =
{
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};
const int W = 4;
const int H = 4;
int brd_get(int x_1, int y_1)
{
    return board[((y_1 * W) + x_1)];
}
int brd_count_empty_spots()
{
    int empty_2 = 0;
    int y_2 = 0;
    while ((y_2 < H))
    {
        int x_2 = 0;
        while ((x_2 < W))
        {
            if ((!brd_get(x_2, y_2)))
            {
                empty_2 = (empty_2 + 1);
                ;
            }
            else
            {
                ;
            }
            x_2 = (x_2 + 1);
            ;
        }
        y_2 = (y_2 + 1);
        ;
    }
    return empty_2;
}
