# encoding: utf-8

module CorrelationAttack

  class LinearFeedbackShiftRegister
    attr_reader :size, :mask, :key

    def initialize(size, mask, key = nil)
      @size, @mask = size, mask
      @key = key || rand(0..largest_key)
    end

    def largest_key
      (2 ** @size) - 1
    end

    def all_keys
      1.upto(largest_key)
    end

    def reset(key)
      LinearFeedbackShiftRegister.new(@size, @mask, key)
    end

    def next
      # Apply the mask using XOR if the output bit is one, otherwise just shift the key
      reset(output_bit.zero? ? (@key << 1) : (@key << 1) ^ @mask)
    end

    def generate_bit_sequence(length)
      # Generate a determenistic sequence of bits of the given length
      lfsrs = (1...length).inject([self]) { |ls| ls << ls.last.next }
      lfsrs.map(&:output_bit).join.to_i(2)
    end

    def output_bit
      (@key & (0b1 << (@size - 1))) >> (@size - 1)
    end
  end

end
