module HashProxy
  class NullObject
    def to_a; []; end
    def to_s; ""; end
    def to_f; 0.0; end
    def to_i; 0; end
    def nil?; true; end
    def blank?; true; end
    def empty?; true; end
    def method_missing(*args)
      self
    end
  end
end
