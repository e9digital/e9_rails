module E9Rails::ActiveRecord
  module STI
    extend ActiveSupport::Concern

    included do 
      scope :of_type,     lambda {|*types| where(:type => types.flatten.map {|t| t.to_s.classify }) }
      scope :not_of_type, lambda {|*types| where(arel_table[:type].in(types.flatten.map {|t| t.to_s.classify }).not) }
    end

    module ClassMethods
      def subclasses
        @_subclasses ||= begin
          # TODO is there a simpler, existing way of finding subclass types with STI

          # TODO make this work with the new arel rewrite (#map is no longer a method)
          #klasses = arel_table.project(Arel::Distinct.new(arel_table[:type])).map {|r| r.tuple.first }
          klasses = connection.select_values("select distinct(type) from #{table_name}")
          klasses.map! {|k| k.constantize rescue next }
          klasses.compact!
          klasses
        end
      end
       
      def subclasses_with_ancestor(mod)
        subclasses.select {|klass| klass.ancestors.include?(mod) }
      end
    end
  end
end
