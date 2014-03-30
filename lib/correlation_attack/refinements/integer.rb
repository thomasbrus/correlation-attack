# encoding: utf-8

module CorrelationAttack
  module Refinements

    module Integer
      refine ::Integer do
        def bit_length
          self.to_s(2).length
        end

        def to_bit_array
          self.to_s(2).each_char.map(&:to_i)
        end

        def hamming_distance(other)
          (self ^ other).to_s(2).count('1')
        end
      end
    end

  end
end
