# frozen_string_literal: true

class SimpleConnection < ActionCable::Connection::Base
  identified_by :user_id

  class << self
    attr_accessor :disconnected_user_id
  end

  def connect
    self.user_id = request.params[:user_id] || cookies[:user_id]
  end

  def disconnect
    self.class.disconnected_user_id = user_id
  end
end

class ConnectionSimpleTest < ActionCable::Connection::TestCase
  tests SimpleConnection

  def test_connected
    connect

    assert_nil connection.user_id
  end

  def test_url_params
    connect "/cable?user_id=323"

    assert_equal "323", connection.user_id
  end

  def test_plain_cookie
    connect cookies: { user_id: "456" }

    assert_equal "456", connection.user_id
  end

  def test_disconnect
    connect cookies: { user_id: "456" }

    assert_equal "456", connection.user_id

    disconnect

    assert_equal "456", SimpleConnection.disconnected_user_id
  end
end

class Connection < ActionCable::Connection::Base
  identified_by :current_user_id
  identified_by :token

  class << self
    attr_accessor :disconnected_user_id
  end

  def connect
    self.current_user_id = verify_user
    self.token = request.headers["X-API-TOKEN"]
  end

  private

    def verify_user
      reject_unauthorized_connection unless cookies.signed[:user_id].present?
      cookies.signed[:user_id]
    end
end

class ConnectionTest < ActionCable::Connection::TestCase
  def test_connected_with_signed_cookies_and_headers
    connect cookies: { user_id: "1123" }, headers: { "X-API-TOKEN" => "abc" }

    assert_equal "abc", connection.token
    assert_equal "1123", connection.current_user_id
  end

  def test_connection_rejected
    assert_reject_connection { connect }
  end
end
