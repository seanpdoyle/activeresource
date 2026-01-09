# frozen_string_literal: true

module ActiveResource
  module FinderMethods
    extend ActiveSupport::Concern

    included do
      delegate :get, :connection, :headers, :new, :format,
        :collection_parser, :instantiate_record,
        :lazy_collections, :element_path, :collection_path,
        to: :resource_class
    end

    # Core method for finding resources. Used similarly to Active Record's +find+ method.
    #
    # ==== Arguments
    # The first argument is considered to be the scope of the query. That is, how many
    # resources are returned from the request. It can be one of the following.
    #
    # * <tt>:one</tt> - Returns a single resource.
    # * <tt>:first</tt> - Returns the first resource found.
    # * <tt>:last</tt> - Returns the last resource found.
    # * <tt>:all</tt> - Returns every resource that matches the request.
    #
    # ==== Options
    #
    # * <tt>:from</tt> - Sets the path or custom method that resources will be fetched from.
    # * <tt>:params</tt> - Sets query and \prefix (nested URL) parameters. Query keys are URL
    #                      encoded using the resource's +query_format+ (the ActiveResource::Formats::UrlEncodedFormat by default).
    #
    # ==== Examples
    #   Person.find(1)
    #   # => GET /people/1.json
    #
    #   Person.find(:all)
    #   # => GET /people.json
    #
    #   Person.find(:all, :params => { :title => "CEO" })
    #   # => GET /people.json?title=CEO
    #
    #   Person.find(:first, :from => :managers)
    #   # => GET /people/managers.json
    #
    #   Person.find(:last, :from => :managers)
    #   # => GET /people/managers.json
    #
    #   Person.find(:all, :from => "/companies/1/people.json")
    #   # => GET /companies/1/people.json
    #
    #   Person.find(:one, :from => :leader)
    #   # => GET /people/leader.json
    #
    #   Person.find(:all, :from => :developers, :params => { :language => 'ruby' })
    #   # => GET /people/developers.json?language=ruby
    #
    #   Person.find(:one, :from => "/companies/1/manager.json")
    #   # => GET /companies/1/manager.json
    #
    #   StreetAddress.find(1, :params => { :person_id => 1 })
    #   # => GET /people/1/street_addresses/1.json
    #
    # == Failure or missing data
    # A failure to find the requested object raises a ResourceNotFound
    # exception if the find was called with an id.
    # With any other scope, find returns nil when no data is returned.
    #
    #   Person.find(1)
    #   # => raises ResourceNotFound
    #
    #   Person.find(:all)
    #   Person.find(:first)
    #   Person.find(:last)
    #   # => nil
    def find(*arguments)
      scope   = arguments.slice!(0)
      options = arguments.slice!(0) || {}
      options.with_defaults!(self.options)

      case scope
      when :all
        find_every(options)
      when :first
        collection = find_every(options)
        collection && collection.first
      when :last
        collection = find_every(options)
        collection && collection.last
      when :one
        find_one(options)
      else
        find_single(scope, options)
      end
    end


    # A convenience wrapper for <tt>find(:first, *args)</tt>. You can pass
    # in all the same arguments to this method as you can to
    # <tt>find(:first)</tt>.
    def first(*args)
      find(:first, *args)
    end

    # A convenience wrapper for <tt>find(:last, *args)</tt>. You can pass
    # in all the same arguments to this method as you can to
    # <tt>find(:last)</tt>.
    def last(*args)
      find(:last, *args)
    end

    # This is an alias for find(:all). You can pass in all the same
    # arguments to this method as you can to <tt>find(:all)</tt>
    def all(options = {})
      if lazy_collections
        merge(options)
      else
        find(:all, options)
      end
    end

    private
      # Find every resource
      def find_every(options)
        params = options[:params]
        prefix_options, query_options = split_options(params)

        response =
          case from = options[:from]
          when Symbol
            get(from, params)
          when String
            path = "#{from}#{query_string(query_options)}"
            format.decode(connection.get(path, headers).body)
          else
            path = collection_path(prefix_options, query_options)
            format.decode(connection.get(path, headers).body)
          end

        instantiate_collection(response || [], query_options, prefix_options)
      rescue ActiveResource::ResourceNotFound
        # Swallowing ResourceNotFound exceptions and return nil - as per
        # ActiveRecord.
        nil
      end

      # Find a single resource from a one-off URL
      def find_one(options)
        prefix_options, query_options = split_options(options[:params])

        case from = options[:from]
        when Symbol
          instantiate_record(get(from, query_options), prefix_options)
        when String
          path = "#{from}#{query_string(query_options)}"
          instantiate_record(format.decode(connection.get(path, headers).body), prefix_options)
        end
      end

      # Find a single resource from the default URL
      def find_single(scope, options)
        prefix_options, query_options = split_options(options[:params])
        path = element_path(scope, prefix_options, query_options)
        instantiate_record(format.decode(connection.get(path, headers).body), prefix_options)
      end

      def instantiate_collection(...)
        collection = resource_class.instantiate_collection(...)
        collection.relation = self
        collection
      end
  end
end
