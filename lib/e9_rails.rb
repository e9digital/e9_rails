require 'rails'

module E9Rails
  autoload :Version, 'e9_rails/version'

  module Helpers
    autoload :Translation,           'e9_rails/helpers/translation'
    autoload :ResourceErrorMessages, 'e9_rails/helpers/resource_error_messages'
  end
end
