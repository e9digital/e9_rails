module E9Rails::ActiveRecord
  module Initialization
    extend ActiveSupport::Concern

    included do
      alias :initialize_without_defaults :initialize

      def initialize(attributes = nil, &block)
        initialize_without_defaults(attributes) do
          self.send(:_assign_initialization_defaults)
          yield self if block_given?
        end
      end
    end

    def _assign_initialization_defaults; end

    protected :_assign_initialization_defaults
  end
end
