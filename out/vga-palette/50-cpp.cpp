inline int builtin_eq_ii(int a, int b) { return a == b; }
inline int builtin_add_ii(int a, int b) { return a + b; }
inline int builtin_sub_ii(int a, int b) { return a - b; }
inline int builtin_mul_ii(int a, int b) { return a * b; }
inline int builtin_lessthan_ii(int a, int b) { return (a < b) ? 1 : 0; }
inline int builtin_lesseq_ii(int a, int b) { return (a <= b) ? 1 : 0; }
inline int builtin_greaterthan_ii(int a, int b) { return (a > b) ? 1 : 0; }
inline int builtin_and_ii(int a, int b) { return a && b; }
inline int builtin_not_i(int a) { return a ? 0 : 1; }

const int my_palette[] =
{
    190, 74, 47, 215, 118, 67, 234, 212, 170, 228, 166, 114, 184, 111, 80, 115, 62, 57, 62, 39, 49, 162, 38, 51, 228, 59, 68, 247, 118, 34, 254, 174, 52, 254, 231, 97, 99, 199, 77, 62, 137, 72, 38, 92, 66, 25, 60, 62, 18, 78, 137, 0, 153, 219, 44, 232, 245, 255, 255, 255, 192, 203, 220, 139, 155, 180, 90, 105, 136, 58, 68, 102, 38, 43, 68, 24, 20, 37, 255, 0, 68, 104, 56, 108, 181, 80, 136, 246, 117, 122, 232, 183, 150, 194, 133, 105
};
const int my_length = 96;
#include <conio.h>
void show_palette()
{
    int _i_2 = 0;
    while (builtin_lessthan_ii(_i_2, 96))
    {
        const int color_2 = my_palette[_i_2];
        palette_put(_i_2, color_2);
        _i_2 = builtin_add_ii(_i_2, 1);;
    }
}
