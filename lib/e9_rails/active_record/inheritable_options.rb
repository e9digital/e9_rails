require 'active_model/naming'
require 'active_model/translation'
require 'active_support/hash_with_indifferent_access'

module E9Rails::ActiveRecord
  module InheritableOptions
    extend ActiveSupport::Concern

    included do
      serialize :options

      class_inheritable_accessor :options_parameters
      self.options_parameters = []

      class_inheritable_accessor :options_class
      self.options_class = Options

      self.options_class.lookup_ancestors = lookup_ancestors
    end

    def options=(hash={})
      write_attribute(:options, hash.stringify_keys)
    end

    def options
      opts = read_attribute(:options) || {}
      opts.reverse_merge! Hash[options_parameters.map(&:to_s).zip([nil])]
      
      options_class.new(opts, self)
    end

    class Options < HashWithIndifferentAccess
      extend ActiveModel::Naming
      extend ActiveModel::Translation

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
