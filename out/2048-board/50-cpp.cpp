inline int builtin_eq_ii(int a, int b) { return a == b; }
inline int builtin_add_ii(int a, int b) { return a + b; }
inline int builtin_sub_ii(int a, int b) { return a - b; }
inline int builtin_mul_ii(int a, int b) { return a * b; }
inline int builtin_lessthan_ii(int a, int b) { return (a < b) ? 1 : 0; }
inline int builtin_lesseq_ii(int a, int b) { return (a <= b) ? 1 : 0; }
inline int builtin_greaterthan_ii(int a, int b) { return (a > b) ? 1 : 0; }
inline int builtin_and_ii(int a, int b) { return a && b; }
inline int builtin_not_i(int a) { return a ? 0 : 1; }

int board[] =
{
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};
const int W = 4;
const int H = 4;
int brd_get(int x_1, int y_1)
{
    return board[builtin_add_ii(builtin_mul_ii(y_1, W), x_1)];
}
int brd_count_empty_spots()
{
    int empty_2 = 0;
    int y_2 = 0;
    while (builtin_lessthan_ii(y_2, H))
    {
        int x_2 = 0;
        while (builtin_lessthan_ii(x_2, W))
        {
            if (builtin_not_i(brd_get(x_2, y_2)))
            {
                empty_2 = builtin_add_ii(empty_2, 1);;
            }
            else
            {
                ;
            }
            x_2 = builtin_add_ii(x_2, 1);;
        }
        y_2 = builtin_add_ii(y_2, 1);;
    }
    return empty_2;
}
