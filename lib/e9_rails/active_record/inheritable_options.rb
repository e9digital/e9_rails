require 'active_model/naming'
require 'active_model/translation'
require 'active_support/hash_with_indifferent_access'

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

      class_inheritable_accessor :options_class
      self.options_class = Options

      class_inheritable_accessor :delegate_options_methods
      self.delegate_options_methods = false

      self.options_class.lookup_ancestors = lookup_ancestors
    end

    def options=(hash={})
      ensuring_method_attributes do
        write_attribute(options_column, hash.stringify_keys)
      end
    end

    def options
      ensuring_method_attributes do
        opts = read_attribute(options_column) || {}
        opts.reverse_merge! Hash[options_parameters.map(&:to_s).zip([nil])]
        options_class.new(opts, self)
      end
    end

    protected

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
        serialized_attributes[self.options_column.to_s].present?
      end

      def initialize_inheritable_options
        return if inheritable_options_initialized?
        serialized_attributes[self.options_column.to_s] = Hash

        if self.delegate_options_methods
          self.options_parameters.each do |param|
            delegate param, "#{param}=", :to => :options
          end
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
