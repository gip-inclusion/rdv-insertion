module TurboStreamConcern
  def turbo_stream_replace_error_list_with(errors)
    render(
      turbo_stream: turbo_stream.replace("error_list", partial: "common/error_list", locals: { errors: }),
      status: :unprocessable_entity
    )
  end

  def turbo_stream_prepend_flash_messages(flash)
    render turbo_stream: turbo_stream.prepend("flashes", partial: "common/flashes", locals: { flash: })
  end

  def turbo_stream_replace_flash_messages(flash)
    render turbo_stream: turbo_stream.replace("flashes", partial: "common/flashes", locals: { flash: })
  end

  def turbo_stream_remove(element_id)
    render turbo_stream: turbo_stream.remove(element_id)
  end

  def turbo_stream_replace(element_id, partial, locals = {})
    render turbo_stream: turbo_stream.replace(element_id, partial:, locals:)
  end

  def turbo_stream_redirect(path)
    render turbo_stream: turbo_stream.action(:redirect, path)
  end

  def turbo_stream_display_modal(partial:, locals: {}, status: :ok)
    render(
      turbo_stream: turbo_stream.replace("remote_modal", partial:, locals:),
      status:
    )
  end

  def turbo_stream_display_error_modal(errors)
    turbo_stream_display_modal(partial: "common/error_modal", locals: { errors: }, status: :unprocessable_entity)
  end

  def turbo_stream_display_success_modal(message)
    turbo_stream_display_modal(partial: "common/success_modal", locals: { message: }, status: :ok)
  end

  def turbo_stream_display_custom_error_modal(errors:, title:, with_support_contact: false)
    turbo_stream_display_modal(
      partial: "common/custom_errors_modal",
      locals: { errors:, title:, with_support_contact: },
      status: :unprocessable_entity
    )
  end
end
