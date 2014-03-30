# encoding: utf-8

module CorrelationAttack

  class StreamCipher
    BYTE_LENGTH = 8

    def initialize(pseudo_random_generator)
      @pseudo_random_generator = pseudo_random_generator
      @buffer = []
    end

    def <<(input_bit)
      @buffer << (@pseudo_random_generator.generate_bit ^ input_bit)
    end

    def read_bit
      @buffer.shift if @buffer.length >= 1
    end

    def read_byte
      @buffer.shift(BYTE_LENGTH).join.to_i(2) if @buffer.length >= BYTE_LENGTH
    end
  end

end
