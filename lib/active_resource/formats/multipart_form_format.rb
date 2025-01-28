# frozen_string_literal: true

module ActiveResource
  module Formats
    class MultipartFormFormat
      delegate :decode, :extension, to: :@format

      def initialize(format)
        @format = format
      end

      def mime_type
        "multipart/form-data"
      end

      def encode(resource, options = nil)
        resource.serializable_hash(options).to_a
      end
    end
  end
end
