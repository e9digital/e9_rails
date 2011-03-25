require 'rails'

module E9Rails
  autoload :Version, 'e9_rails/version'

  module Helpers
    autoload :Translation,           'e9_rails/helpers/translation'
    autoload :ResourceErrorMessages, 'e9_rails/helpers/resource_error_messages'
    autoload :Title,                 'e9_rails/helpers/title'
    autoload :Pagination,            'e9_rails/helpers/pagination'
  end

  module ActiveRecord
    autoload :STI,                   'e9_rails/active_record/sti'
    autoload :AttributeSearchable,   'e9_rails/active_record/attribute_searchable'
    autoload :InheritableOptions,    'e9_rails/active_record/inheritable_options'
  end
end
