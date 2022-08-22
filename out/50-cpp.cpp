int factorial(int n);

int factorial(int n) {
  int $placeholder$;
  if (builtin_=(n, 0))
  {
    $placeholder$ = 1;
  }
  else
  {
    $placeholder$ = builtin_*(n, factorial(builtin_-(n, 1)));
  }
  return $placeholder$;
}
