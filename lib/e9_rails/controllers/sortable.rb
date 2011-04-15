module E9Rails::Controllers
  #
  # Module to give a controller "sortable" functionality.
  #
  # To implement this there must exist a POST route to the collection url
  # named update_order which passes an array, "ids", representing the new order, e.g.
  #
  # resources :sortable_things do
  #   collection { post :update_order }
  # end
  #
  module Sortable
    extend ActiveSupport::Concern

    def update_order(options = {}, &block)
      if params[:ids].is_a?(Array)
        pos = 0
        params[:ids].each {|id| pos += 1; _do_position_update(id, :position => pos) }
        flash[:notice] = I18n.t(:notice, :scope => :"flash.actions.update_order")
      else
        flash[:alert]  = I18n.t(:alert,  :scope => :"flash.actions.update_order")
      end
      
      block ||= proc {|format| format.js { head :ok } }

      respond_with(collection, &block)
    end

    alias :update_order! :update_order

    #
    # Override _do_position_update in your controller to define a different method to 
    # update a record's position.
    #
    # The out-of-the-box implementation assumes two things:
    #
    # 1. An InheritedResources controller
    # 2. A vanilla (position column) acts_as_list install.
    #
    def _do_position_update(id, hash_with_position)
      resource_class.update(id, hash_with_position)
    end

    private :_do_position_update
  end
end
