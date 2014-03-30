# encoding: utf-8

module CorrelationAttack
  class LinearFeedbackShiftRegister

    # Combines several LFSRs and generates bits using the given binary boolean function
    class Combinator
      include DSL
      attr_reader :lfsrs, :combinator_function

      def generate_bit
        @combinator_function.call(*output_bits).tap { tick }
      end

      def generate_bit_sequence(length)
        Array.new(length) { generate_bit }.join.to_i(2)
      end

      def tick
        @lfsrs = @lfsrs.map { |lfsr| lfsr.next }
      end

      def output_bits
        @lfsrs.map(&:output_bit)
      end
    end

  end
end
