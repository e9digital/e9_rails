module E9Rails::ActiveRecord
  module AttributeSearchable
    extend ActiveSupport::Concern

    included do
      scope :attr_like,      lambda {|*args| where(attr_like_scope_condition(*args))       }
      scope :any_attrs_like, lambda {|*args| where(any_attrs_like_scope_conditions(*args)) }
    end

    module ClassMethods
      def attr_like_scope_condition(attr_name, string, opts = {})
        matcher = opts.delete(:matcher) || "%%%s%%"
        arel_table[attr_name].matches(matcher % string)
      end

      def any_attrs_like_scope_conditions(*args)
        opts   = args.extract_options!
        string = args.pop
        args.flatten.map {|attr_name| attr_like_scope_condition(attr_name, string, opts) }.inject(&:or)
      end
    end
  end
end
