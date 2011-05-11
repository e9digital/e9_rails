require 'rails'

module E9Rails
  autoload :Version, 'e9_rails/version'

  module ActiveRecord
    autoload :AttributeSearchable,   'e9_rails/active_record/attribute_searchable'
    autoload :InheritableOptions,    'e9_rails/active_record/inheritable_options'
    autoload :Initialization,        'e9_rails/active_record/initialization'
    autoload :STI,                   'e9_rails/active_record/sti'
  end

  module Controllers
    autoload :Orderable,             'e9_rails/controllers/orderable'
    autoload :Sortable,              'e9_rails/controllers/sortable'
  end

  module Helpers
    autoload :Pagination,            'e9_rails/helpers/pagination'
    autoload :ResourceErrorMessages, 'e9_rails/helpers/resource_error_messages'
    autoload :ResourceLinks,         'e9_rails/helpers/resource_links'
    autoload :Title,                 'e9_rails/helpers/title'
    autoload :Translation,           'e9_rails/helpers/translation'
  end
end
