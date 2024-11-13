module TurboStreamConcern
  def turbo_stream_replace_error_list_with(errors)
    render(
      turbo_stream: turbo_stream.replace("error_list", partial: "common/error_list", locals: { errors: }),
      status: :unprocessable_entity
    )
  end

  def turbo_stream_prepend_flash_message(flash)
    render turbo_stream: turbo_stream.prepend("flashes", partial: "common/flash", locals: { flash: })
  end

  def turbo_stream_replace_flash_message(flash)
    render turbo_stream: turbo_stream.replace("flashes", partial: "common/flash", locals: { flash: })
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

  def turbo_stream_display_custom_error_modal(errors:, title:)
    turbo_stream_display_modal(partial: "common/custom_errors_modal", locals: { errors:, title: },
                               status: :unprocessable_entity)
  end
end
