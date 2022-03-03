# frozen_string_literal: true

OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
  provider: "github",
  uid: 12345,
  info: {
    nickname: "user",
    image: "https://example.com"
  }
})
