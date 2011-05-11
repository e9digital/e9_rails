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

        errors = object.errors.map {|attribute, msg| msg }.flatten.map {|m| "<li>#{m}</li>"}.join("\n")

        <<-HTML.html_safe
          <div id="errorExplanation">
            <ul>#{errors}</ul>
          </div>
        HTML
      rescue => e
        ''
      end
    end
  end
end
