module E9Rails::Helpers
  module Title
    extend ActiveSupport::Concern

    included do 
      helper_method Helpers
    end

    module Helpers
      def site_name
        raise NotImplementedError, "You must implement a site_name helper to use the Title helpers"
      end

      def meta_title(title = nil, options = {})
        [title || @_title, send(:site_name)].flatten.compact.map {|t| sanitize(t) }.join(options[:delimiter] || ' - ').html_safe
      end

      def title(*args)
        options = args.extract_options!

        if !args.empty?
          @_title     = args.dup
          base_title = sanitize(args.shift)

          options[:class] = [options[:class], 'title'].compact.join(' ')
          options[:class].concat(' error') if options[:error]

          unless options[:hide_title]
            content = base_title
            content = content_tag(options[:inner_tag], content) if options[:inner_tag]

            content_tag(:h1, options.slice(:id, :class)) do
              ''.tap do |html|
                html.concat options[:prepend] if options[:prepend]
                html.concat content
                html.concat options[:append] if options[:append]
              end
            end
          end
        end
      end
    end
  end
end
