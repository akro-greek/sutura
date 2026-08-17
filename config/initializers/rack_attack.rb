class Rack::Attack
  throttle("api/ip", limit: 120, period: 1.minute) do |request|
    request.ip if request.path.start_with?("/api/")
  end

  self.throttled_responder = lambda do |_request|
    [ 429, { "Content-Type" => "application/json", "Retry-After" => "60" }, [ { error: "rate_limited" }.to_json ] ]
  end
end
