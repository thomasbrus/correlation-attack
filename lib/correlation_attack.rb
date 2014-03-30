# encoding: utf-8

require 'correlation_attack/version'
require 'correlation_attack/linear_feedback_shift_register'
require 'correlation_attack/linear_feedback_shift_register/combinator/dsl'
require 'correlation_attack/linear_feedback_shift_register/combinator'
require 'correlation_attack/stream_cipher'
require 'correlation_attack/refinements/integer'

module CorrelationAttack
  using Refinements::Integer

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

  def self.brute_force_key(lfsr, known_keystream)
    lfsr.all_keys.find do |key|
      # Have the caller build a lfsr combinator with the proposed key
      lfsr_combinator = yield(lfsr.reset(key))

      # Generate a bit sequence from this lfsr combinator
      kk_length = known_keystream.bit_length
      generated_keystream = lfsr_combinator.generate_bit_sequence(kk_length)

      # Return the current key if there is a match
      known_keystream == generated_keystream
    end
  end
end
