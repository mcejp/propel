inline int builtin_eq_ii(int a, int b) { return a == b; }
inline int builtin_add_ii(int a, int b) { return a + b; }
inline int builtin_sub_ii(int a, int b) { return a - b; }
inline int builtin_mul_ii(int a, int b) { return a * b; }
inline int builtin_lessthan_ii(int a, int b) { return (a < b) ? 1 : 0; }
inline int builtin_lesseq_ii(int a, int b) { return (a <= b) ? 1 : 0; }
inline int builtin_greaterthan_ii(int a, int b) { return (a > b) ? 1 : 0; }
inline int builtin_and_ii(int a, int b) { return a && b; }
inline int builtin_not_i(int a) { return a ? 0 : 1; }

int my_palette[] =
{
    1, 2, 3, 4
};
int my_length = 4;
void show_palette()
{
    int scope2_i = 0;
    while (builtin_lesseq_ii(scope2_i, 4))
    {
        int scope2_j = scope2_i;
        scope2_i = builtin_add_ii(scope2_i, 1);;
    }
}
