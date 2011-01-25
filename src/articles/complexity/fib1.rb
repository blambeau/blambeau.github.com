require 'rubygems'
require 'minitest/autorun'
require 'minitest/benchmark'

class BenchFib < MiniTest::Unit::TestCase
  
  def fib n
    a, b = 0, 1
    n.times{ a, b = b, a + b }
    a
  end
  
  def bench_fib
    assert_performance_linear 0.99 do |n|
      n.times do fib(1000) end
    end
  end
  
end