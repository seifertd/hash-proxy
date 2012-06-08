module HashProxy
  class Proxy
    NO_OBJECT = NullObject.new
    EQUALS = '='.freeze

    def initialize(hash, options = {})
      @hash = hash
      @converted = {}
    end

    def method_missing(name, *args)
      name_str = name.to_s
      if name_str.end_with?(EQUALS)
        @converted[name_str[0..-2]] = convert_value(args.first)
      else
        # Move the value from the original hash to the converted hash.
        # Support both symbol or string keys
        @converted[name_str] ||= convert_value(@hash.delete(name) || @hash.delete(name_str))
      end
    end

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
