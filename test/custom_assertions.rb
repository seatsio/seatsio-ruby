require 'minitest/assertions'

module Minitest::Assertions
  private
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

  def assert_false(actual)
    assert_equal(false, actual)
  end

  def assert_not_equal(expected, actual)
    assert_operator(expected, :!=, actual)
  end

  def assert_empty(actual)
    assert_equal([], actual)
  end

  def assert_not_instance_of(expected_class, actual)
    refute_instance_of(expected_class, actual)
  end

end
