module UploadedAttachmentSanitizer
  def sanitize_uploaded_attachment(uploaded_attachment)
    
  end

  def sanitize_uploaded_attachments(uploaded_attachments)
    uploaded_attachments.map do |attachment|
      sanitize_uploaded_attachment(attachment)
    end
  end
end
