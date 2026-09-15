class RdvSolidaritesOauthToken < ApplicationRecord
  belongs_to :agent

  encrypts :api_token, :refresh_token

  def refresh!(expired_api_token)
    # Refreshing rotates the token on rdv-solidarites, which is an irreversible external side effect:
    # once rds hands us a new refresh token, the previous one is revoked on their side. We persist the
    # new token on a dedicated connection (hence the thread) so that a rollback of the caller's
    # transaction cannot revert our write. Otherwise we would keep a token rds has already revoked and
    # every subsequent refresh would fail with invalid_grant.
    Thread.new do
      # join re-raises the exception in the caller, so we silence the redundant $stderr warning
      Thread.current.report_on_exception = false

      self.class.connection_pool.with_connection do
        with_lock do
          # another process might have refreshed the token while we waited for the lock
          next if api_token != expired_api_token

          access_token = RdvSolidaritesOauthClient.new(api_token:, refresh_token:).refresh!
          update!(api_token: access_token.token, refresh_token: access_token.refresh_token)
        end
      end
    end.join
  end
end
