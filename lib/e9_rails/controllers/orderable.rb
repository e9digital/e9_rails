module E9Rails::Controllers
  # A hackish has_scope mixin to allow ordering by database column.
  #
  # Requires has_scope and inherited_resources.
  #
  module Orderable
    extend ActiveSupport::Concern

    included do
      helper HelperMethods

      helper_method :default_ordered_dir

      has_scope :order, :if => :ordered_if, :default => lambda {|c| c.send(:default_ordered_on) } do |controller, scope, columns|
        resource_class = controller.send(:resource_class)

        begin
          # determine the dir from params or controller default
          dir = case controller.params[:sort]
                when /^desc$/i then 'DESC'
                when /^asc$/i  then 'ASC'
                else controller.try(:default_ordered_dir) || ''
                end

          # split the ordered_param on commas and periods, the idea being that 
          # it can take multiple columns, and on assocation columns
          columns = columns.split(',').map {|n| n.split('.') }

          columns = columns.map {|v| 
            # if column split on '.', try to constantize the parsed class
            if v.length > 1 && v.last =~ /\w+/
              klass = v.first.classify.constantize rescue nil

              # and if it succeeds
              if klass
                # apply the join to the scope.
                # NOTE there's no checking whatsoever here as to:
                #      A.) is this class an association?
                #      B.) does this class have the passed column?
                scope = scope.includes(v.first.underscore.to_sym)
                "#{klass.table_name}.#{v.last} #{dir}"
              end
            elsif v.last =~ /\w+/
              sql = ''

              if resource_class.column_names.member?(v.last)
                sql << "#{resource_class.table_name}."
              end

              sql << "#{v.last} #{dir}"
            end
          }.compact.join(', ')

          scope.order(columns)
        rescue => e
          Rails.logger.error("Orderable ordered_on scope : #{e.message}")
          scope
        end
      end
    end

    def default_ordered_on 
      'created_at' 
    end

    def default_ordered_dir 
      'DESC' 
    end

    def ordered_if 
      params[:action] == 'index' 
    end

    module HelperMethods
      def orderable_column_link(column, override_name = nil)
        link_text = resource_class.human_attribute_name(override_name || column)

        column = column.join(',') if column.is_a?(Array)

        co, lo = if params[:order] == column.to_s
          params[:sort] =~ /^desc$/i ? %w(DESC ASC) : %w(ASC DESC)
        else
          [nil, default_ordered_dir.presence || 'DESC']
        end

        css_classes = ["order-gfx", co, "h-#{lo}"].compact.join(' ').downcase

        content_tag(:div, :class => 'ordered-column') do
          link_to(link_text, :order => column, :sort => lo).safe_concat tag(:span, :class => css_classes)
        end
      end
    end
  end
end
