module PdfGeneration
  class Generate < BaseService
    def initialize(content:, context: {})
      @content = content
      @context = context
    end

    def call
      response = PdfGeneratorClient.generate_pdf(content: @content)
      handle_response(response)
    rescue Faraday::TimeoutError => e
      handle_error(:timeout, exception: e.class.name, message: e.message)
    rescue Faraday::ConnectionFailed => e
      handle_error(:connection_failed, exception: e.class.name, message: e.message)
    end

    private

    def handle_response(response)
      if response.success?
        result.pdf_data = Base64.decode64(response.body)
      else
        handle_error(:server_error, status: response.status, body: response.body)
      end
    end

    def handle_error(error_type, extra_info = {})
      Sentry.capture_message("PDF generation failed", extra: @context.merge(extra_info))
      result.error_type = error_type
      fail!(error_message(error_type))
    end

    def error_message(error_type)
      case error_type
      when :timeout
        "La génération du PDF a pris trop de temps. Veuillez réessayer dans quelques instants."
      when :connection_failed
        "Le service de génération de PDF est temporairement indisponible. Veuillez réessayer plus tard."
      when :server_error
        "Une erreur est survenue lors de la génération du PDF. " \
        "L'équipe a été notifiée de l'erreur et tente de la résoudre."
      end
    end
  end
end
