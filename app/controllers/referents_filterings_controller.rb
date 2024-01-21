class ReferentsFilteringsController < ApplicationController
  before_action :set_referents_list, only: [:new]

  def new; end

  private

  def set_referents_list
    @referents_list = current_structure.agents
  end
end
