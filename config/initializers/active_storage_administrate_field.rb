# as draw_routes is set to false in production, we need to redirect the calls to the url and blob_url methods
# because administrate use them

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
