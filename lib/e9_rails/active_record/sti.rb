module E9Rails::ActiveRecord
  module STI
    extend ActiveSupport::Concern

    included do 
      scope :of_type,     lambda {|*types| where(:type => types.flatten.map {|t| t.to_s.classify }) }
      scope :not_of_type, lambda {|*types| where(arel_table[:type].in(types.flatten.map {|t| t.to_s.classify }).not) }
    end

    module ClassMethods
      def subclasses
        descendants
      end
       
      def subclasses_with_ancestor(mod)
        subclasses.select {|klass| klass.ancestors.include?(mod) }
      end
    end
  end
end
