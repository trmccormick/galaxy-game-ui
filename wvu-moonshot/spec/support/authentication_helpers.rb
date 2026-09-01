# Helpers for request specs. The app restricts access to modern browsers
# (allow_browser versions: :modern), so every request is sent with a modern
# browser user agent.
module RequestHelpers
  def get(path, **args)
    super(path, **args.merge(headers: { "User-Agent" => MODERN_BROWSER_UA }))
  end

  def post(path, **args)
    super(path, **args.merge(headers: { "User-Agent" => MODERN_BROWSER_UA }))
  end

  def patch(path, **args)
    super(path, **args.merge(headers: { "User-Agent" => MODERN_BROWSER_UA }))
  end

  def delete(path, **args)
    super(path, **args.merge(headers: { "User-Agent" => MODERN_BROWSER_UA }))
  end
end

# Signs a user in through the real sign-in flow (POST /session), which creates
# the session and sets the signed cookie the same way a browser would.
module AuthenticationHelpers
  def sign_in(user, password: "Moonshot2026!")
    post session_path, params: { email_address: user.email_address, password: password }
  end

  def sign_out
    delete session_path
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
  config.include AuthenticationHelpers, type: :request

  # Current.session is thread-local and the signed session cookie persists in
  # the Rack::Test cookie jar, so both would leak between request specs. Reset
  # them before each example to guarantee a clean (unauthenticated) start.
  config.before(:each, type: :request) do
    Current.session = nil
    # Clear the session cookie by setting it to nil/blank. This ensures
    # find_session_by_cookie won't find a valid session.
    cookies[:session_id] = nil
  end
end
