module SignOutHelper
  def sign_out_link
    { url: sign_out_path, options: { data: { turbo: false } } }
  end
end
