# encoding: utf-8

module CorrelationAttack
  class LinearFeedbackShiftRegister

    # Combines several LFSRs and generates bits using the given binary boolean function.
    # @example A simple LFSR combinator with two LFSRs.
    #   LinearFeedbackShiftRegister::Combinator.build do
    #     add_lfsr LinearFeedbackShiftRegister.new(4, 0b1010, 0b0110)
    #     add_lfsr LinearFeedbackShiftRegister.new(4, 0b1000, 0b1100)
    #
    #     define_combinator_function do |first_lfsr_bit, second_lfsr_bit|
    #       first_lfsr_bit & second_output_bit
    #     end
    #   end
    #
    class Combinator
      include DSL

      # @return [Array] a list of registered linear feedback shift registers
      attr_reader :lfsrs

      # @return [Proc] the function that combines the output of the registered LFSRs.
      attr_reader :combinator_function

      # Calls the combinator function and outputs the result.
      # @note This action is irreverible and shifts all the registered LFSRs.
      # @see #tick
      # @return [Integer] the generated bit
      # @api public
      def generate_bit
        @combinator_function.call(*output_bits).tap { tick }
      end

      # Generates a sequence of bits.
      # @see #generate_bit
      # @param length [Integer] the desired length of the bit sequence
      # @return [Integer] the generated bit sequence
      # @api public
      def generate_bit_sequence(length)
        Array.new(length) { generate_bit }.join.to_i(2)
      end

      # Synchronously shifts all the registered LFSRs.
      # @api public
      def tick
        @lfsrs = @lfsrs.map { |lfsr| lfsr.next }
      end

      # @return [Array] an output bit for each registered LFSR.
      # @api public
      def output_bits
        @lfsrs.map(&:output_bit)
      end
    end

  end
end
