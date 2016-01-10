require 'minitest/autorun'
require 'debt_collector'

class DebtCollectorTest < Minitest::Test
  def test_something
    assert_equal "hello world", DebtCollector.collect
  end
end
