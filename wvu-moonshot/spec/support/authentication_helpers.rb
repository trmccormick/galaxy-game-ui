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

  # Current.session is thread-local and would leak between request specs, so
  # reset it before each one to guarantee a clean (unauthenticated) start.
  config.before(:each, type: :request) { Current.session = nil }
end
