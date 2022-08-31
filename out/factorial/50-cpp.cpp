int factorial(int n)
{
  int $placeholder$;
  if (builtin_eq_ii(scope2_n, 0))
  {
    $placeholder$ = 1;
  }
  else
  {
    $placeholder$ = builtin_mul_ii(scope2_n, scope1_factorial(builtin_sub_ii(scope2_n, 1)));
  }
  return $placeholder$;
}
