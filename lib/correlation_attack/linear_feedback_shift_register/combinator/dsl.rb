# encoding: utf-8

module CorrelationAttack
  class LinearFeedbackShiftRegister
    class Combinator

      # Provides a nice interface for building LFSR combinators.
      module DSL
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          # Builds a new Combinator which is configured by the supplied block.
          # @yield [generator] a yet to be configured Combinator instance
          # @return [Combinator]
          # @api public
          def build(&block)
            new.tap { |generator| generator.instance_eval(&block) }
          end
        end

        # Adds a linear feedback shift register to the combinator.
        # @param lfsr [LinearFeedbackShiftRegister] the to be added linear
        #   feedback shift register instance
        # @api public
        def add_lfsr(lfsr)
          (@lfsrs ||= []) << lfsr
        end

        # Sets the function that combines the outputs of the LFSRs using a
        # binary boolean function.
        # @example
        #   define_combinator_function do |first_lfsr_bit, second_output_bit|
        #     first_lfsr_bit & second_output_bit
        #   end
        #
        # @param function [Proc] the combinator function
        # @api public
        def define_combinator_function(&function)
          @combinator_function = function
        end
      end

    end
  end
end
