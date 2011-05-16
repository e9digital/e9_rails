require 'rails'

module E9Rails
  autoload :Version, 'e9_rails/version'

  module ActiveRecord
    autoload :AttributeSearchable,   'e9_rails/active_record/attribute_searchable'
    autoload :InheritableOptions,    'e9_rails/active_record/inheritable_options'
    autoload :Initialization,        'e9_rails/active_record/initialization'
    autoload :STI,                   'e9_rails/active_record/sti'

    module Scopes
      autoload :Times,               'e9_rails/active_record/scopes/times'
    end
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

  class Railtie < Rails::Railtie
    initializer 'e9_rails.append_i18n_translations' do
      require 'active_support/i18n'
      I18n.load_path << File.join(File.dirname(__FILE__), 'e9_rails/locale/en.yml')
    end
  end
end
