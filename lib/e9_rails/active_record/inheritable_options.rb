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
      write_attribute(:options, hash)
    end

    def options
      self.class.options_class.new( (read_attribute(:options) || {}).reverse_merge(Hash[options_parameters.zip([nil])]), self)
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
