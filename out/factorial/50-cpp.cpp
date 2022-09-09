inline int builtin_eq_ii(int a, int b) { return a == b; }
inline int builtin_add_ii(int a, int b) { return a + b; }
inline int builtin_sub_ii(int a, int b) { return a - b; }
inline int builtin_mul_ii(int a, int b) { return a * b; }
inline int builtin_lessthan_ii(int a, int b) { return (a < b) ? 1 : 0; }
inline int builtin_greaterthan_ii(int a, int b) { return (a > b) ? 1 : 0; }
inline int builtin_and_ii(int a, int b) { return a && b; }
inline int builtin_not_i(int a) { return a ? 0 : 1; }

int factorial(int scope2_n)
{
    int tmp3;
    if (builtin_eq_ii(scope2_n, 0))
    {
        tmp3 = 1;
    }
    else
    {
        tmp3 = builtin_mul_ii(scope2_n, factorial(builtin_sub_ii(scope2_n, 1)));
    }
    return tmp3;
}
