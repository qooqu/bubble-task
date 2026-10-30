# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data
    policy.img_src     :self, :data, "https://bubbletask.goatcounter.com"
    policy.object_src  :none
    policy.script_src  :self, "https://gc.zgo.at"
    policy.style_src   :self
    policy.connect_src :self, "https://bubbletask.goatcounter.com"
    policy.base_uri    :self
    policy.form_action :self
    policy.frame_ancestors :none
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  # The nonce is kept in the session rather than using its id, which is nil on a first visit.
  config.content_security_policy_nonce_generator = ->(request) { request.session[:csp_nonce] ||= SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end
