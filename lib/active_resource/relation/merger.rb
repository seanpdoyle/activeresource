# frozen_string_literal: true

require "active_support/core_ext/hash/keys"

module ActiveResource
  class Relation
    class HashMerger # :nodoc:
      attr_reader :relation, :hash

      def initialize(relation, hash)
        hash.assert_valid_keys(:from, :params)

        @relation = relation
        @hash     = hash
      end

      def merge
        Merger.new(relation, other).merge
      end

      # Applying values to a relation has some side effects. E.g.
      # interpolation might take place for where values. So we should
      # build a relation to merge in rather than directly merging
      # the values.
      def other
        other = Relation.new(relation.resource_class)

        if (params = hash[:params])
          other.where!(params)
        end

        if (path = hash[:from])
          other.from!(path)
        end

        other
      end
    end

    class Merger # :nodoc:
      attr_reader :relation, :other

      def initialize(relation, other)
        @relation = relation
        @other    = other
      end

      def merge
        relation.from_clause = other.from_clause if replace_from_clause?

        where_clause = relation.where_clause.merge(other.where_clause)
        relation.where_clause = where_clause unless where_clause.empty?

        relation
      end

      private
        def replace_from_clause?
          relation.from_clause.empty? && !other.from_clause.empty?
        end
    end
  end
end
