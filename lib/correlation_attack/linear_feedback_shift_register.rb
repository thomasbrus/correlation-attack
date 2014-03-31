# encoding: utf-8

module CorrelationAttack

  # Implementation of a
  # {http://en.wikipedia.org/wiki/Linear_feedback_shift_register linear feedback shift register}.
  class LinearFeedbackShiftRegister
    # @return [Integer] the size of the register
    attr_reader :size

    # @return [Integer] the position of the XORs as a binary number
    attr_reader :mask

    # @return [Integer] the contents of the register
    attr_reader :key

    # Initializes a LinearFeedbackShiftRegister.
    # @example
    #   # Creates an LFSR with a register that contains 4 bits.
    #   # The XOR's are placed at the 4th and 2nd position (counting backwards),
    #   # and the register is initialized with the bit sequence 0110.
    #
    #   LinearFeedbackShiftRegister.new(4, 0b1010, 0b0110)
    #
    # @param size [Integer] the size of the register
    # @param mask [Integer] the bitmask that indicates where the XOR's are located
    # @param key [Integer] the encryption key, chosen randomly if omitted
    # @return [LinearFeedbackShiftRegister]
    # @api public
    def initialize(size, mask, key = nil)
      @size, @mask = size, mask
      @key = key || rand(0..largest_key)
    end

    # @return [Integer] the largest possible key for this register
    # @api public
    def largest_key
      (2 ** @size) - 1
    end

    # @return [Enumerator] an enumerator with all possible keys
    # @api public
    def all_keys
      1.upto(largest_key)
    end

    # Resets the LFSR to the given key.
    # @note This function returns a new LFSR instance.
    # @param key [Integer] the new key
    # @return [LinearFeedbackShiftRegister]
    # @api public
    def reset(key)
      LinearFeedbackShiftRegister.new(@size, @mask, key)
    end

    # Shifts the register and applies the XOR mask, depending on the output bit.
    # @note This function returns a new LFSR instance.
    # @return [LinearFeedbackShiftRegister] an LFSR with the updated register
    # @api public
    def next
      reset(output_bit.zero? ? (@key << 1) : (@key << 1) ^ @mask)
    end

    # Generates a sequence of bits, leaving the LFSR unmodified.
    # @param length [Integer] the desired length of the bit sequence
    # @return [Integer] the generated bit sequence
    # @api public
    def generate_bit_sequence(length)
      lfsrs = (1...length).inject([self]) { |ls| ls << ls.last.next }
      lfsrs.map(&:output_bit).join.to_i(2)
    end

    # Returns the leftmost bit of the register.
    # @return [Integer] the output bit
    # @api public
    def output_bit
      (@key & (0b1 << (@size - 1))) >> (@size - 1)
    end
  end

end
