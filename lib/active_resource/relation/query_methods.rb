# frozen_string_literal: true

module ActiveResource
  module QueryMethods
    include ActiveModel::ForbiddenAttributesProtection

    def from(path)
      spawn.from!(path)
    end

    def from!(path) # :nodoc:
      self.from_clause = path
      self
    end

    # This is an alias for all. You can pass in all the same
    # arguments to this method as you can to <tt>all</tt> and <tt>find(:all)</tt>
    def where(clauses = {})
      spawn.where!(clauses)
    end

    def where!(clauses = {}) # :nodoc:
      clauses = sanitize_forbidden_attributes(clauses)
      raise ArgumentError, "expected a clauses Hash, got #{clauses.inspect}" unless clauses.is_a? Hash

      self.where_clause += Relation::WhereClause.new([ clauses ])
      self
    end

    def from_clause
      @values.fetch(:from_clause, Relation::FromClause.empty)
    end

    def from_clause=(value)
      @values[:from_clause] = value
    end

    def where_clause
      @values.fetch(:where_clause, Relation::WhereClause.empty)
    end

    def where_clause=(value)
      @values[:where_clause] = value
    end

    def original_params
      where_clause.to_h
    end

    private
      def options
        {
          params: original_params,
          from: from_clause
        }
      end
  end
end
