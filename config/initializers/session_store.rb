Rails.application.config.session_store(
  :cookie_store,
  key: "_rdv_insertion_session",
  expire_after: 2.hours
)
