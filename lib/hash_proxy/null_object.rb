module HashProxy
  # Class representing a non-existing key in a proxied
  # hash.  Returns self in response to any message.  Returns
  # sensible values for various to_* methods.  But it
  # is not 'false-y' ... ;)
  class NullObject
    # Returns an empty array
    def to_a; []; end

    # Returns an empty array
    def to_ary; []; end

    # Returns an empty string
    def to_s; ""; end

    # Returns an empty string
    def to_str; ""; end

    # Returns 0.0
    def to_f; 0.0; end

    # Returns 0
    def to_i; 0; end

    # Always true
    def nil?; true; end

    # Always true
    def blank?; true; end

    #Always true
    def empty?; true; end

    # Returns self in response to any message
    def method_missing(*args)
      self
    end
  end
end
