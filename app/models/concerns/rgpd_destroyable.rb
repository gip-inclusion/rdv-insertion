module RgpdDestroyable
  extend ActiveSupport::Concern

  def mark_for_rgpd_destruction
    @marked_for_rgpd_destruction = true
  end

  def marked_for_rgpd_destruction?
    @marked_for_rgpd_destruction == true
  end
end
