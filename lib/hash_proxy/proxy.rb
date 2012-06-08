module HashProxy
  # Class that wraps a hash and converts message sends to
  # hash lookups and sets. If sent a message ending with '=',
  # sets a value.  Otherwise, returns the value in the
  # hash at the key corresponding to the message.  If the
  # key does not exist, returns a NullObject instance.
  class Proxy
    # The one and only NullObject instance
    NO_OBJECT = NullObject.new

    # Used to check if a setter is being called
    EQUALS = '='.freeze

    # Create a hashProxy::Proxy object from the provided Hash.
    #
    # @param [Hash] hash The hash we are proxying
    # @option options [Boolean] :lazy (true) If true, values in the hash are converted
    #     to hash proxies only when requested via
    #     a method call.  If false, all nested Hash
    #     and Array objects are converted to Proxy
    #     objects at creation time
    def initialize(hash, options = {})
      @hash = hash
      @converted = {}
    end

    # The magic.  Turns arbitrary method invocations into
    # lookups or sets on the contained hash
    def method_missing(name, *args)
      name_str = name.to_s
      if name_str.end_with?(EQUALS)
        @converted[name_str[0..-2]] = convert_value(args.first)
      else
        # Move the value from the original hash to the converted hash.
        # Support both symbol or string keys
        if @converted.has_key?(name_str)
          @converted[name_str]
        else
          unconverted = @hash.delete(name) || @hash.delete(name_str)
          converted = convert_value(unconverted)
          @converted[name_str] = converted
        end
      end
    end

    # Try to do the right thing.  Indicate that this object
    # responds to any getter or setter method with a corresponding
    # key in either the original or converted hash.  This can lead to 
    # possibly confusing behavior:
    #
    #    p = Proxy.new(:foo => :bar)
    #    p.respond_to?(:stuff) => false
    #    p.stuff => NullObject
    #    p.respond_to?(:stuff) => true
    #
    def respond_to?(method)
      method_name = method.to_s
      method_name.gsub(/=$/, '')
      (@hash.keys.map(&:to_s) + @converted.keys.map(&:to_s)).include?(method_name) || super
    end

    # Converts an arbitrary object as follows:
    #
    #   1. A Proxy instance if the object is an instance of Hash
    #   2. If the object is an array, all elements of the array
    #      that are hashes are converted to Proxy objects.
    #      Nested arrays are handled recursivley.
    #   3. Non array or hash objects are left alone
    #   4. nil is replaced by Proxy::NO_VALUE
    #
    # @param [Object] value The value to convert
    def convert_value(value)
      case value
      when Array
        value.map! {|array_value| convert_value(array_value)}
        value
      when Hash
        Proxy.new(value)
      else
        value || NO_OBJECT
      end
    end
  end
end
