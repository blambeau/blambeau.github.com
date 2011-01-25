def fib n
  a, b = 0, 1
  (2**n).times{ a, b = b, a + b }
  a
end