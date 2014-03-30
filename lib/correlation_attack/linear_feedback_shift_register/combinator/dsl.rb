module CorrelationAttack
  class LinearFeedbackShiftRegister
    class Combinator

      module DSL
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def build(&block)
            new.tap { |generator| generator.instance_eval(&block) }
          end
        end

        def add_lfsr(lfsr)
          (@lfsrs ||= []) << lfsr
        end

        def define_combinator_function(&function)
          @combinator_function = function
        end
      end

    end
  end
end
