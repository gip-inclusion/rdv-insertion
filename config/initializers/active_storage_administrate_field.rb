module Administrate
  module Field
    class ActiveStorage < Administrate::Field::Base
      def url(attachment)
        attachment.url
      end

      def blob_url(attachment)
        attachment.url
      end
    end
  end
end
