require 'rubygems'
require 'minitest/autorun'
require 'minitest/benchmark'

class BenchFib < MiniTest::Unit::TestCase
  
  # def self.bench_range
  #   [1, 10, 50, 125, 250, 500, 1000]
  # end
  
  def fib n
    a, b = 0, 1
    n.times do 
      a, b = b, a + b 
    end
    a
  end
  
  def bench_fib
    assert_performance_power 0.99 do |n|
      n.times do 
        fib(n) 
      end
    end
  end
  
end