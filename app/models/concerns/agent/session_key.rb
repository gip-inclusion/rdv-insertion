module Agent::SessionKey
  extend ActiveSupport::Concern

  def generate_session_key!
    update!(session_key: self.class.generate_unique_secure_token)
  end

  def retrieve_or_generate_session_key!
    generate_session_key! unless session_key
    session_key
  end

  def rotate_session_key! = generate_session_key!
end
