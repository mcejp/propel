int factorial(int n);

int factorial(int n) {
  int $placeholder$;
  if (builtin_eq_ii(n, 0))
  {
    $placeholder$ = 1;
  }
  else
  {
    $placeholder$ = builtin_mul_ii(n, factorial(builtin_sub_ii(n, 1)));
  }
  return $placeholder$;
}
