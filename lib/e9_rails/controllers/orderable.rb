module E9Rails::Controllers
  # A hackish has_scope mixin to allow ordering by database column.
  #
  # Requires has_scope and inherited_resources.
  #
  module Orderable
    extend ActiveSupport::Concern

    def default_ordered_on; 'created_at' end

    def default_ordered_dir; 'DESC' end

    def ordered_if; params[:action] == 'index' end

    included do
      has_scope :ordered_on, :if => :ordered_if, :default => lambda {|c| c.send(:default_ordered_on) } do |controller, scope, val|
        begin
          # determine the dir from params or controller default
          dir = case controller.params[:dir]
                when /^desc$/i then 'DESC'
                when /^asc$/i  then 'ASC'
                else controller.send(:default_ordered_dir) rescue ''
                end

          # split the ordered_param on commas and periods, the idea being that 
          # it can take multiple columns, and on assocation columns
          val = val.split(',').map {|v| v.split('.') }

          val = val.map {|v| 
            # if val split on '.', try to constantize the parsed class
            if v.length > 1
              klass = v.first.classify.constantize rescue nil
              # and if it succeeds
              if klass
                # apply the join to the scope.
                # NOTE there's no checking whatsoever here as to:
                #      A.) is this class an association?
                #      B.) does this class have the passed column?
                scope = scope.joins(v.first.underscore.to_sym)
                "#{klass.table_name}.#{v.last} #{dir}"
              end
            else
              # else we're assuming the column is on the table
              "#{resource_class.table_name}.#{v.last} #{dir}"
            end
          }.compact.join(', ')

          scope.order(val)
        rescue => e
          raise e
          scope
        end
      end
    end
  end
end
