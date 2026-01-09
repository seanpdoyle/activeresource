# frozen_string_literal: true

module ActiveResource
  class Relation
    class FromClause # :nodoc:
      attr_reader :value

      def self.empty
        @empty ||= new(nil).freeze
      end

      def initialize(value)
        @value = value
      end

      def merge(other)
        self
      end

      def empty?
        value.nil?
      end

      def ==(other)
        value == other.value
      end
    end
  end
end
