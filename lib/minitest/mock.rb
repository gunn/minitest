class MockExpectationError < StandardError; end

##
# A simple and clean mock object framework.

module MiniTest

  ##
  # All mock objects are an instance of Mock

  class Mock
    def initialize # :nodoc:
      @expected_calls = {}
      @actual_calls = Hash.new {|h,k| h[k] = [] }
    end

    ##
    # Expect that method +name+ is called, optionally with +args+, and
    # returns +retval+.
    #
    #   @mock.expect(:meaning_of_life, 42)
    #   @mock.meaning_of_life # => 42
    #
    #   @mock.expect(:do_something_with, true, [some_obj, true])
    #   @mock.do_something_with(some_obj, true) # => true

    def expect(name, retval, args=[])
      @expected_calls[name] = { :retval => retval, :args => args }
      
      eigenclass = class << self; self; end
      eigenclass.send :define_method, name do |*given_args|
        raise ArgumentError unless args.size == given_args.size
        @actual_calls[name] << { :retval => retval, :args => given_args }
        retval
      end
      
      self
    end

    ##
    # Verify that all methods were called as expected. Raises
    # +MockExpectationError+ if the mock object was not called as
    # expected.

    def verify
      @expected_calls.each_key do |name|
        expected = @expected_calls[name]
        msg = "expected #{name}, #{expected.inspect}"
        raise MockExpectationError, msg unless
          @actual_calls.has_key? name and @actual_calls[name].include?(expected)
      end
      true
    end

    alias :original_respond_to? :respond_to?
    def respond_to?(sym) # :nodoc:
      return true if @expected_calls.has_key?(sym)
      return original_respond_to?(sym)
    end
  end
end
