module E9Rails::Helpers
  module ResourceLinks
    extend ActiveSupport::Concern

    included do
      helper HelperMethods

      unless self._helper_methods.member?(:parent)
        def parent; end
        protected :parent
        helper_method :parent
      end
    end

    module HelperMethods
      def link_to_resource(resource, options = {})
        options.symbolize_keys!

        path_options = options.slice!(:scope, :action, :method, :remote, :confirm, :class)

        klass  = resource.is_a?(Class) ? resource : resource.class

        action = (options.delete(:action) || :show).to_sym

        if klass == resource && ![:index, :new].member?(action)
          action = :index
        end

        scopes  = [*(options[:scope] || @route_scope), parent].compact
        path    = case action
                  when :new;   new_polymorphic_path(scopes << klass, path_options)
                  when :edit;  edit_polymorphic_path(scopes << resource, path_options)
                  when :index; polymorphic_path(scopes << klass, path_options)
                  else         polymorphic_path(scopes << resource, path_options)
                  end

        mn = klass.model_name

        translation_options = {
          :model      => mn.human,
          :models     => mn.human.pluralize,
          :collection => mn.collection,
          :element    => mn.element
        }
        
        if action == :destroy
          defaults = klass.lookup_ancestors.map {|k|
            :"#{klass.i18n_scope}.links.#{k.model_name.underscore}.confirm_destroy"
          } << :"#{klass.i18n_scope}.links.confirm_destroy"

          options[:method] = :delete
          options.reverse_merge!({
            :remote  => true, 
            :confirm => I18n.t(defaults.shift, translation_options.merge(:default => defaults))
          })
        end

        #
        # Mimic ActiveModel's lookup chain for attributes
        #
        defaults = klass.lookup_ancestors.map do |k|
          :"#{klass.i18n_scope}.links.#{k.model_name.underscore}.#{action}"
        end

        defaults << :"#{klass.i18n_scope}.links.#{action}"
        defaults << action.to_s.humanize

        link_to I18n.t(defaults.shift, translation_options.merge(:default => defaults)), path, options
      end

      def link_to_show_resource(resource, options = {})
        link_to_resource(resource, options.merge(:action => :show))
      end

      def link_to_edit_resource(resource, options = {})
        link_to_resource(resource, options.merge(:action => :edit))
      end

      def link_to_new_resource(resource, options = {})
        link_to_resource(resource, options.merge(:action => :new))
      end

      def link_to_destroy_resource(resource, options = {})
        link_to_resource(resource, options.merge(:action => :destroy))
      end

      def link_to_collection(resource, options = {})
        link_to_resource(resource, options.merge(:action => :index))
      end
    end
  end
end
