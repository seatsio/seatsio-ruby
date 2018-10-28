require 'minitest/assertions'

module Minitest::Assertions
  def assert_between(actual, start, finish)
    assert actual >= start
    assert actual <= finish
  end

  def assert_not_nil(actual)
    assert_operator(actual, :!=, nil)
  end

  def assert_true(actual)
    assert_equal(true, actual)
  end

  def assert_not_blank(actual)
    assert_operator(actual, :!=, '')
  end
end
