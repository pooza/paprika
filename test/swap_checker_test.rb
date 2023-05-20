module Paprika
  class SwapCheckerTest < TestCase
    def setup
      @checker = SwapChecker.new
    end

    def test_value
      assert_kind_of(Hash, @checker.value)
    end

    def test_message
      assert_kind_of(String, @checker.message)
    end

    def test_warn
      assert_boolean(@checker.warn?)
    end

    def test_error
      assert_boolean(@checker.error?)
    end
  end
end
