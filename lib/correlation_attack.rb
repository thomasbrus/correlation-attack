# encoding: utf-8

require 'correlation_attack/version'
require 'correlation_attack/linear_feedback_shift_register'
require 'correlation_attack/linear_feedback_shift_register/combinator/dsl'
require 'correlation_attack/linear_feedback_shift_register/combinator'
require 'correlation_attack/stream_cipher'
require 'correlation_attack/refinements/integer'
require 'correlation_attack/refinements'

# Contains two convenience methods for executing a
# {http://en.wikipedia.org/wiki/Correlation_attack correlation attack}.
module CorrelationAttack
  using Refinements

  # Guesses the key of an LFSR, given a known keystream produced by an LFSR combinator.
  # @note This will only result in a correct key if the LFSR is correlated to
  #   the LFSR combinator that produced the keystream. Whether or not this is
  #   the case depends on the combinator function.
  # @example
  #   lfsr = LinearFeedbackShiftRegister.new(4, 0b1010, 0b0110)
  #   known_keystream = 0b10010111011100001100110001000100110101011100010111000011
  #
  #   CorrelationAttack.guess_key(lfsr, known_keystream)
  #
  # @param lfsr [LinearFeedbackShiftRegister] the linear feedback shift register for
  #   which the key is unkown
  # @param known_keystream [Integer] the guessed or intercepted output of an LFSR
  #   combinator
  # @return [Integer] the most likely key given the keystream
  # @api public
  def self.guess_key(lfsr, known_keystream)
    lfsr.all_keys.map { |key|
      [key, lfsr.reset(key)]
    }.map { |(key, lfsr)|
      # Generate a sequence of bits from the proposed key
      [key, lfsr.generate_bit_sequence(known_keystream.bit_length)]
    }.map { |(key, generated_output)|
      # Compare the generated output to the known keystream
      [key, known_keystream.hamming_distance(generated_output)]
    }.min_by(&:last).first
  end

  # Brute forces a key by comparing the output of a user-supplied LFSR combinator
  # against the known keystream.
  # @example
  #   # Given an LFSR of which the key is known, and one of which the key is unknown...
  #   solved_lfsr = CorrelationAttack::LinearFeedbackShiftRegister.new(4, 0b1000, 0b1101)
  #   unsolved_lfsr = CorrelationAttack::LinearFeedbackShiftRegister.new(4, 0b1110)
  #
  #   # And given an intercepted or guessed keystream...
  #   known_keystream = 0b10010111011100001100110001000100110101011100010111000011
  #
  #   # Find the key by building the LFSR combinator from the solved LFSR and a proposed LFSR.
  #   # All possible keys for the unsolved LFSR are tried and yielded to the block.
  #   CorrelationAttack.brute_force_key(unsolved_lfsr, known_keystream) do |proposed_lfsr|
  #     CorrelationAttack::LinearFeedbackShiftRegister::Combinator.build do
  #       add_lfsr solved_lfsr
  #       add_lfsr proposed_lfsr
  #
  #       define_combinator_function do |first_lfsr_bit, second_lfsr_bit|
  #         first_lfsr_bit & second_lfsr_bit
  #       end
  #     end
  #   end
  #
  # @param lfsr [LinearFeedbackShiftRegister] the LFSR for which the key is unkown
  # @param known_keystream [Integer] the guessed or intercepted output of an LFSR
  #   combinator
  # @yieldparam lfsr [LinearFeedbackShiftRegister] the supplied LFSR configured
  #   with the guessed key
  # @yieldreturn [LinearFeedbackShiftRegister::Combinator] an LFSR combinator that
  #   uses the supplied LFSR
  # @return [Integer] the key if a match is found
  # @api public
  def self.brute_force_key(lfsr, known_keystream)
    lfsr.all_keys.find do |key|
      # Have the caller build an LFSR combinator with the proposed key
      lfsr_combinator = yield(lfsr.reset(key))

      # Generate a bit sequence from this lfsr combinator
      keystream_length = known_keystream.bit_length
      generated_keystream = lfsr_combinator.generate_bit_sequence(keystream_length)

      # Return the current key if there is a match
      known_keystream == generated_keystream
    end
  end
end
