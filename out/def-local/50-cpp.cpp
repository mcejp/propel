inline int builtin_eq_ii(int a, int b) { return a == b; }
inline int builtin_add_ii(int a, int b) { return a + b; }
inline int builtin_sub_ii(int a, int b) { return a - b; }
inline int builtin_mul_ii(int a, int b) { return a * b; }
inline int builtin_lessthan_ii(int a, int b) { return (a < b) ? 1 : 0; }
inline int builtin_greaterthan_ii(int a, int b) { return (a > b) ? 1 : 0; }
inline int builtin_and_ii(int a, int b) { return a && b; }
inline int builtin_not_i(int a) { return a ? 0 : 1; }

int scope2_add(int scope3_a, int scope3_b)
{
    int scope4_left = scope3_a;
    ;
    int scope4_right = scope3_b;
    ;
    int scope4_sum = builtin_add_ii(scope4_left, scope4_right);
    ;
    return scope4_sum;
}
