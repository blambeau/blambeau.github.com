require 'rubygems'
require 'minitest/autorun'
require 'minitest/benchmark'

class BenchFib < MiniTest::Unit::TestCase
  
  def fib n
    a, b = 0, 1
    (2**n).times{ a, b = b, a + b }
    a
  end
  
  def bench_fib
    assert_performance_linear 0.99 do |n|
      n.times{ fib(10) }
    end
  end
  
end