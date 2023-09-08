class RdvsController < ApplicationController
  before_action :set_rdv, only: [:edit, :update]

  def edit; end

  def update
    Rdvs::Update.call(
      rdv: @rdv,
      attributes: rdv_params,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  private

  def set_rdv
    @rdv = Rdv.find(params[:id])
  end

  def rdv_params
    params.require(:rdv).permit(:status)
  end
end
