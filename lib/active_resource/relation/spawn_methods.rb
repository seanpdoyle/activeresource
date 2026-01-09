# frozen_string_literal: true

require "active_resource/relation/merger"

module ActiveResource
  module SpawnMethods
    def spawn
      clone
    end

    def merge(other) # :nodoc:
      if other
        spawn.merge!(other)
      else
        raise ArgumentError, "invalid argument: #{other.inspect}."
      end
    end

    def merge!(other) # :nodoc:
      if other.is_a?(Hash)
        Relation::HashMerger.new(self, other).merge
      elsif other.is_a?(Relation)
        Relation::Merger.new(self, other).merge
      else
        raise ArgumentError, "#{other.inspect} is not an ActiveResource::Relation"
      end
    end
  end
end
