# encoding: utf-8

module CorrelationAttack

  # Encrypts a stream of bits by XORing them with a pseudorandom keystream.
  # Note that this cipher is symmetrical (encrypting twice with the same keystream returns
  # the original plaintext).
  # @example
  #   # Suppose we have some kind of pseudorandom number generator...
  #   class MyPseudorandomNumberGenerator
  #     def initialize
  #       @lfsr = LinearFeedbackShiftRegister.new(4, 0b1010, 0b0110)
  #     end
  #
  #     def generate_bit
  #       @lfsr.output_bit.tap { tick }
  #     end
  #
  #     def tick
  #       @lfsr = @lfsr.next
  #     end
  #   end
  #
  #   # And we want to encrypt this plaintext
  #   plaintext = 'Hello world'
  #   stream_cipher = StreamCipher.new(pseudorandom_number_generator)
  #
  #   # Then the plaintext needs to be transformated to a bit array
  #   # and each bit should be fed to the stream cipher
  #   bits = plaintext.unpack('B*').first.each_char.map(&:to_i)
  #   bits.each { |bit| stream_cipher << bit }
  #
  #   # The encrypted bits can then be read from the stream cipher
  #   # and tranformed back into ASCII (although this results in unreadable characters)
  #   encrypted_bits = bits.length.times.map { stream_cipher.read_bit }
  #   ciphertext = [encrypted_bits.join].pack('B*')
  #
  class StreamCipher
    # The number of bits in a byte.
    BYTE_LENGTH = 8

    # Initializes a StreamCipher.
    # @param pseudorandom_number_generator [#generate_bit] an object that outputs pseudorandom bits
    # @return [StreamCipher]
    # @api public
    def initialize(pseudorandom_number_generator)
      @pseudorandom_number_generator = pseudorandom_number_generator
      @buffer = []
    end

    # Encrypt and append a bit to the input buffer.
    # @param input_bit [Integer] the input bit
    # @api public
    def <<(input_bit)
      @buffer << (@pseudorandom_number_generator.generate_bit ^ input_bit)
    end

    # Read a single encrypted bit from the buffer.
    # @note This shifts the bit from the beginning of the buffer.
    # @return [Integer] an encrypted bit
    def read_bit
      @buffer.shift if @buffer.length >= 1
    end

    # Read eight encrypted bits at once from the buffer.
    # @note This shifts the bits from the beginning of the buffer.
    # @return [Integer] an encrypted byte
    def read_byte
      @buffer.shift(BYTE_LENGTH).join.to_i(2) if @buffer.length >= BYTE_LENGTH
    end
  end

end
