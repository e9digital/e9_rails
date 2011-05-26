require 'active_model/naming'
require 'active_model/translation'
require 'active_support/hash_with_indifferent_access'
require 'ostruct'

module E9Rails::ActiveRecord
  module InheritableOptions
    extend ActiveSupport::Concern

    included do
      #
      # NOTE 
      #
      attribute_method_suffix "_with_inheritable_options"

      class_inheritable_accessor :options_column
      self.options_column = :options

      class_inheritable_accessor :options_parameters
      self.options_parameters = []

      class_inheritable_accessor :delegate_options_methods
      self.delegate_options_methods = false

      class_inheritable_accessor :options_class
    end

    def options=(hash)
      ensuring_method_attributes do
        write_options(hash || {})
      end
    end

    def options
      ensuring_method_attributes do
        opts = read_options
        opts.reverse_merge! Hash[options_parameters.map(&:to_s).zip([nil])]
        options_class.new(opts, self)
      end
    end

    protected

    def write_options(hash)
      write_attribute(options_column, (hash || {}).stringify_keys)
    end

    def read_options
      read_attribute(options_column) || {}
    end

    def ensuring_method_attributes
      yield
    rescue
      if !self.class.attribute_methods_generated?
        self.class.define_attribute_methods
        retry
      else
        raise $!
      end
    end

    module ClassMethods
      def define_method_attribute_with_inheritable_options(attr_name)
        initialize_inheritable_options
      end

      def inheritable_options_initialized?
        !!@inheritable_options_initialized
      end

      def initialize_inheritable_options
        return if inheritable_options_initialized?

        self.options_class ||= self.options_parameters.present? ? Options : IndifferentOptions
        self.options_class.lookup_ancestors = lookup_ancestors

        if self.options_column
          serialized_attributes[self.options_column.to_s] = Hash
        end

        if self.delegate_options_methods
          self.options_parameters.each do |param|
            delegate param, "#{param}=", :to => :options
          end
        end

        @inheritable_options_initialized = true
      end
    end

    class IndifferentOptions < OpenStruct
      extend ActiveModel::Naming
      extend ActiveModel::Translation

      # implementation of lookup_ancestors for AM & i18n
      class_inheritable_accessor :lookup_ancestors

      attr_reader :base

      class << self
        def name; 'Options' end
        def i18n_scope; :activerecord end
      end

      def extractable_options?
        false
      end

      def initialize(hash, base)
        @table = {}
        for k,v in hash
          new_ostruct_member(k)
          @table[k.to_sym] = v
        end
        @base = base
      end

      def to_hash
        @table
      end

      # we respond to anything!
      def respond_to?(method_name)
        true
      end

      def new_ostruct_member(name)
        name = name.to_sym
        unless @table.keys.member?(name)
          class << self; self; end.class_eval do
            define_method(name) { @table[name] }
            define_method("#{name}=") do |x| 
              modifiable[name] = x
              @base.options = to_hash
              modifiable[name]
            end
          end
        end
        name
      end

      # If OpenStruct first generates the new_ostruct_member methods with
      # a setter, it does not use the newly generated methods to set the
      # attribute the first time, but rather does this:
      #
      #   modifiable[new_ostruct_member(mname)] = args[0]
      #
      # Because of this it's necessary to explicitly call the newly created
      # setter after new_ostruct_member does its job to ensure that
      # @base.options is written.
      #
      def method_missing(mid, *args)
        super

        if mid.id2name =~ /=$/
          send(mid, *args)
        end
      end
    end

    class Options < HashWithIndifferentAccess
      extend ActiveModel::Naming
      extend ActiveModel::Translation

      # implementation of lookup_ancestors for AM & i18n
      class_inheritable_accessor :lookup_ancestors

      attr_reader :base

      class << self
        def name; 'Options' end
        def i18n_scope; :activerecord end
      end

      # This is for active_support, signifying that this class shouldn't be 
      # extracted from *args as options via extract_options.  If this is NOT set,
      # we'll get some odd errors when trying to build the form.
      def extractable_options?
        false
      end

      def initialize(hash, base)
        merge!(hash)
        @base = base
        class << self; self; end.class_eval do
          hash.each do |k, v|
            define_method(k) { self[k] }
            define_method("#{k}=") do |v| 
              self[k] = v
              @base.options = Hash[self]
              self[k]
            end
          end
        end
      end
    end
  end
end
