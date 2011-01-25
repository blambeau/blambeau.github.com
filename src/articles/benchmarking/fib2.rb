assert_performance_linear 0.99 do |n|
  n.times do |n|
    fib(1000)
  end
end
