module E9Rails::Helpers
  module Translation
    extend ActiveSupport::Concern

    included do
      extend InstanceMethods
      helper_method :e9_t, :e9_translate
    end

    module InstanceMethods
      def e9_translate(lookup_key, opts = {})
        # TODO is there a nicer way to say this?
        defaults = []

        lookup_key = lookup_key.to_s

        # if a scoped key is passed assume it's fully scoped (after e9)
        if lookup_key.include?(".")
          defaults << lookup_key
          # reset the key for base lookup
          lookup_key = lookup_key.split('.').last

        # elsif scope is passed, delete it and use the path as the first default
        elsif scope = opts.delete(:scope)
          # this lets you pass scope as an empty string
          scope = nil if scope.blank?
          defaults << (Array.wrap(scope) << lookup_key).compact.join('.')

        # the difference between default and scope is that default expects a key,
        # ignoring the lookup key
        elsif default = opts.delete(:default)
          defaults << default
        end

        # append default lookup of controller path, e.g. "e9.admin.foos.lookup_key"
        defaults << [controller_path.gsub(/\//, '.'), lookup_key].join('.')

        # and after that, base lookup for the key
        defaults << lookup_key

        # sym them and clean up possible accidental double dots
        defaults.map! {|default| [:e9, default].join('.').gsub(/\.+/, '.').to_sym }
        defaults.uniq!

        lookup_key = defaults.shift

        begin
          model_name = (opts.delete(:resource_class) || resource_class).model_name
          opts.reverse_merge!(
            :model      => model_name.human,
            :models     => model_name.human.pluralize,
            :collection => model_name.collection,
            :element    => model_name.element
          )
        rescue
        end

        ::I18n.translate(lookup_key, opts.merge(:default => defaults))
      end

      alias :e9_t :e9_translate
    end
  end
end
