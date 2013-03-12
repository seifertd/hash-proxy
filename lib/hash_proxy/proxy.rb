module HashProxy
  # Class that wraps a hash and converts message sends to
  # hash lookups and sets. If sent a message ending with '=',
  # sets a value.  Otherwise, returns the value in the
  # hash at the key corresponding to the message.  If the
  # key does not exist, returns a NullObject instance.
  class Proxy
    include Enumerable
    # The one and only NullObject instance
    NO_OBJECT = NullObject.new

    # Used to check if a setter is being called
    EQUALS = '='.freeze

    # Serialization
    def marshal_dump
      [@hash, @converted]
    end

    # Deserialization
    def marshal_load(array)
      @hash = array[0]
      @converted = array[1]
    end

    # Create a hashProxy::Proxy object from the provided Hash.
    #
    # @param [Hash] hash The hash we are proxying
    def initialize(hash)
      @hash = hash
      @converted = {}
    end

    # Returns the number of values stored in the underlying hash
    #
    # @return [Integer]
    def size
      @hash.size + @converted.size
    end

    # Get all keys in this hash proxy
    def keys
      (@hash.keys + @converted.keys)
    end

    # Get all keys in this hash proxy
    def values
      (@hash.values + @converted.values)
    end

    # Yields to the provided block all the values in this Hash proxy.  All values
    # are converted via #convert_value as they are yielded.  The order in which
    # values are yielded is not deterministic.  Insertion order in the original 
    # hash may be lost if some values are already converted.
    def each(&blk)
      enum = Enumerator.new do |y|
        @converted.each {|k, v| y.yield(k,v) }
        @hash.each {|k,v| y.yield(k, self.move_value(k)) }
      end
      if blk.nil?
        enum
      else
        enum.each do |k,v|
          blk.call(k,v)
        end
      end
    end

    # Returns the converted value in the original
    # hash associated with the given key
    #
    # @param [Object] key The value to look up
    # @return [Object] The object associated with the key
    def [](key)
      # Return the value if it has already been converted
      if @converted.has_key?(key)
        @converted[key]
      else
        # Move the value from the original hash to the converted hash.
        # Support both symbol or string keys
        self.move_value(key)
      end
    end

    # Sets a value after converting it to a Proxy if necessary
    #
    # @param [Object] key The key of the value to set
    # @param [Object] value The value to set
    def []=(key, value)
      @converted[key] = convert_value(value)
    end

    # Handle conversion to json
    def to_json(options = nil)
      @hash.merge(@converted).to_json(options)
    end

    # Turns arbitrary method invocations into
    # lookups or sets on the contained hash
    def method_missing(name, *args)
      name_str = name.to_s
      if name_str.end_with?(EQUALS)
        # Handle edge case (self.send(:"=", 'foo') ? why would someone do this)
        if name_str != EQUALS
          self[name_str[0..-2].to_sym] = args.first
        else
          super
        end
      else
        self[name]
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
      (@hash && @converted && (@hash.keys.map(&:to_s) + @converted.keys.map(&:to_s)).include?(method_name)) || super
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
        value.nil? ? NO_OBJECT : value
      end
    end

    # moves a value from the original hash to the converted
    # hash after converting the value to a proxy if necessary
    def move_value(name, name_str = name.to_s)
      unconverted = if @hash.has_key?(name)
        @hash.delete(name)
      elsif @hash.has_key?(name_str)
        @hash.delete(name_str)
      else
        nil
      end
      @converted[name] = self.convert_value(unconverted)
    end

  end

end
