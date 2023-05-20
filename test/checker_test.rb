module Paprika
  class CheckerTest < TestCase
    def setup
      @checker = Checker.new
    end

    def test_ohai
      assert_kind_of(Ohai::System, @checker.ohai)
    end

    def test_platform
      assert(['freebsd', 'ubuntu'].member?(@checker.platform))
    end
  end
end
