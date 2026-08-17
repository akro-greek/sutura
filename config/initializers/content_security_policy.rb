Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src :self, :data
    policy.img_src :self, :data, :blob, "https://cdn.jsdelivr.net", "https://scrollprize.org"
    policy.object_src :none
    policy.script_src :self, "https://esm.sh"
    policy.style_src :self, :unsafe_inline
    policy.connect_src :self, "https://esm.sh", "https://scrollprize.org"
    policy.base_uri :self
    policy.frame_ancestors :none
  end

  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
