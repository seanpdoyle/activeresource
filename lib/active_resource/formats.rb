# frozen_string_literal: true

module ActiveResource
  module Formats
    autoload :XmlFormat, "active_resource/formats/xml_format"
    autoload :JsonFormat, "active_resource/formats/json_format"
    autoload :MultipartFormFormat, "active_resource/formats/multipart_form_format"
    autoload :UrlEncodedFormat, "active_resource/formats/url_encoded_format"

    # Lookup the format class from a mime type reference symbol. Example:
    #
    #   ActiveResource::Formats[:xml]  # => ActiveResource::Formats::XmlFormat
    #   ActiveResource::Formats[:json] # => ActiveResource::Formats::JsonFormat
    #   ActiveResource::Formats[multipart_form: :xml]   # => ActiveResource::Formats::MultipartFormFormat
    #   ActiveResource::Formats[multipart_form: :json]  # => ActiveResource::Formats::MultipartFormFormat
    def self.[](mime_type_reference)
      if mime_type_reference.is_a?(Hash) && (content_type, accept = mime_type_reference.first)
        self[content_type].new(self[accept])
      else
        case mime_type_reference.to_s
        when "xml" then XmlFormat
        when "json" then JsonFormat
        else ActiveResource::Formats.const_get(ActiveSupport::Inflector.camelize(mime_type_reference.to_s) + "Format")
        end
      end
    end

    def self.remove_root(data)
      if data.is_a?(Hash) && data.keys.size == 1 && data.values.first.is_a?(Enumerable)
        data.values.first
      else
        data
      end
    end
  end
end
