module E9Rails::Helpers
  #
  # Simple helper to compile errors on a record in mostly-typical Rails
  # style, with the assumption that the current record is available as
  # <tt>resource</tt>.
  #
  module ResourceErrorMessages
    extend ActiveSupport::Concern

    included do
      send :helper, HelperMethods
    end

    module HelperMethods
      #
      # Assumes the definition of <tt>resource</tt>.
      # Also accepts it as an option passed to the method.
      #
      def resource_error_messages!(options = {})
        object = options[:resource] || resource

        if object.errors.empty? || ( (errors_on = options.delete(:on)) && (errors_on & object.errors.keys).empty? )
          return ''
        end

        messages = object.errors.map {|attribute, msg| content_tag(:li, msg) }.join
        html     = <<-HTML
          <div id="errorExplanation">
            <ul>#{messages}</ul>
          </div>
        HTML

        html.html_safe
      rescue => e
        ''
      end
    end
  end
end
