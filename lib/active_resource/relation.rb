# frozen_string_literal: true

require "active_resource/relation/finder_methods"
require "active_resource/relation/from_clause"
require "active_resource/relation/query_methods"
require "active_resource/relation/spawn_methods"
require "active_resource/relation/where_clause"

module ActiveResource
  class Relation
    include Enumerable
    include FinderMethods, QueryMethods, SpawnMethods

    attr_reader :resource_class, :loaded

    delegate :create, :split_options, :query_string, to: :resource_class
    delegate :each, :size,
      :first_or_initialize, :first_or_create,
      :encode, :original_parsed,
      to: :collection

    def initialize(resource_class, values: {})
      @resource_class = resource_class
      @values = values
      @collection = nil
      @loaded = false
    end

    def load
      unless @loaded
        @collection = resource_class.find(:all, options)
        @loaded = true
      end

      self
    end

    def reload
      reset
      load
    end

    def collection
      load
      @collection
    end

    def ==(other)
      case other
      when Relation
        resource == other.resource && values == other.values
      when Array, Collection
        collection == other
      end
    end

    protected
      attr_reader :values

    private
      def reset
        @collection = nil
        @offsets = nil
        @loaded = false
      end
  end
end
