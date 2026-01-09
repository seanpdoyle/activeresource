# frozen_string_literal: true

module ActiveResource
  class Relation
    class WhereClause # :nodoc:
      delegate :any?, :empty?, to: :predicates

      def self.empty
        @empty ||= new([]).freeze
      end

      def initialize(predicates)
        @predicates = predicates.compact
      end

      def +(other)
        WhereClause.new(predicates + other.predicates)
      end

      def merge(other)
        WhereClause.new(predicates | other.predicates)
      end

      def to_h
        predicates.reduce({}, :merge!)
      end

      protected
        attr_reader :predicates
    end
  end
end
