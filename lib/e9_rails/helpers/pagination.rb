module E9Rails::Helpers
  module Pagination
    extend ActiveSupport::Concern

    included do
      class_inheritable_accessor :pagination_page_param
      self.pagination_page_param = :page

      class_inheritable_accessor :pagination_per_page_param
      self.pagination_per_page_param = :per_page

      class_inheritable_accessor :pagination_per_page_default
      self.pagination_per_page_default = 10

      class_inheritable_accessor :pagination_feed_per_page_default
      self.pagination_feed_per_page_default = 50

      before_filter :pagination_parameters

      helper_method :paging_page, :pagination_per_page, :paging?
    end

    protected

    def pagination_per_page
      if request.format.to_s =~ /rss/
        self.class.pagination_feed_per_page_default
      else
        self.class.pagination_per_page_default
      end
    end

    def pagination_parameters
      @pagination_parameters ||= pagination_defaults.dup.tap do |opts|
        if page = params[self.class.pagination_page_param]
          opts[self.class.pagination_page_param] = page
        end

        if per_page = params.delete(self.class.pagination_per_page_param)
          opts[self.class.pagination_per_page_param] = per_page
        end
      end
    end

    def paging_page
      pagination_parameters[self.class.pagination_page_param] || 1
    end

    def paging?
      !!params[self.class.pagination_page_param]
    end

    def pagination_defaults
      { self.class.pagination_page_param => 1, self.class.pagination_per_page_param => pagination_per_page }
    end
  end
end
