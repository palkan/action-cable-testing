# frozen_string_literal: true

require "active_support"
require "active_support/test_case"
require "active_support/core_ext/hash/indifferent_access"
require "action_dispatch/testing/test_request"

module ActionCable
  module Connection
    class NonInferrableConnectionError < ::StandardError
      def initialize(name)
        super "Unable to determine the connection to test from #{name}. " +
          "You'll need to specify it using tests YourConnection in your " +
          "test case definition."
      end
    end

    module Assertions
      # Asserts that the connection is rejected (via +reject_unauthorized_connection+).
      #
      #   # Asserts that connection without user_id fails
      #   assert_reject_connection { connect cookies: { user_id: '' } }
      def assert_reject_connection(&block)
        res =
          begin
            block.call
            false
          rescue ActionCable::Connection::Authorization::UnauthorizedError
            true
          end

        assert res, "Expected to reject connection but no rejection were made"
      end
    end

    class TestRequest < ActionDispatch::TestRequest
      attr_reader :cookie_jar

      module CookiesStub
        # Stub signed cookies, we don't need to test encryption here
        def signed
          self
        end
      end

      def cookie_jar=(val)
        @cookie_jar = val.tap do |h|
          h.singleton_class.include(CookiesStub)
        end
      end
    end

    module ConnectionStub
      attr_reader :logger, :request

      def initialize(path, cookies, headers)
        @logger = ActiveSupport::TaggedLogging.new ActiveSupport::Logger.new(StringIO.new)

        uri = URI.parse(path)
        env = {
          "QUERY_STRING" => uri.query,
          "PATH_INFO" => uri.path
        }.merge(build_headers(headers))

        @request = TestRequest.create(env)
        @request.cookie_jar = cookies.with_indifferent_access
      end

      def build_headers(headers)
        headers.each_with_object({}) do |(k, v), obj|
          k = k.upcase
          k.tr!("-", "_")
          obj["HTTP_#{k}"] = v
        end
      end
    end

    # Superclass for Action Cable connection unit tests.
    #
    # == Basic example
    #
    # Unit tests are written as follows:
    # 1. First, one uses the +connect+ method to simulate connection.
    # 2. Then, one asserts whether the current state is as expected (e.g. identifiers).
    #
    # For example:
    #
    #   module ApplicationCable
    #     class ConnectionTest < ActionCable::Connection::TestCase
    #       def test_connects_with_cookies
    #         # Simulate a connection
    #         connect cookies: { user_id: users[:john].id }
    #
    #         # Asserts that the connection identifier is correct
    #         assert_equal "John", connection.user.name
    #     end
    #
    #     def test_does_not_connect_without_user
    #       assert_reject_connection do
    #         connect
    #       end
    #     end
    #   end
    #
    # You can also provide additional information about underlying HTTP request:
    #   def test_connect_with_headers_and_query_string
    #     connect "/cable?user_id=1", headers: { "X-API-TOKEN" => 'secret-my' }
    #
    #     assert_equal connection.user_id, "1"
    #   end
    #
    # == Connection is automatically inferred
    #
    # ActionCable::Connection::TestCase will automatically infer the connection under test
    # from the test class name. If the channel cannot be inferred from the test
    # class name, you can explicitly set it with +tests+.
    #
    #   class ConnectionTest < ActionCable::Connection::TestCase
    #     tests ApplicationCable::Connection
    #   end
    #
    class TestCase < ActiveSupport::TestCase
      module Behavior
        extend ActiveSupport::Concern

        include ActiveSupport::Testing::ConstantLookup
        include Assertions

        included do
          class_attribute :_connection_class

          attr_reader :connection

          ActiveSupport.run_load_hooks(:action_cable_connection_test_case, self)
        end

        module ClassMethods
          def tests(connection)
            case connection
            when String, Symbol
              self._connection_class = connection.to_s.camelize.constantize
            when Module
              self._connection_class = connection
            else
              raise NonInferrableConnectionError.new(connection)
            end
          end

          def connection_class
            if connection = self._connection_class
              connection
            else
              tests determine_default_connection(name)
            end
          end

          def determine_default_connection(name)
            connection = determine_constant_from_test_name(name) do |constant|
              Class === constant && constant < ActionCable::Connection::Base
            end
            raise NonInferrableConnectionError.new(name) if connection.nil?
            connection
          end
        end

        # Performs connection attempt (i.e. calls #connect method).
        #
        # Accepts request path as the first argument and cookies and headers as options.
        def connect(path = "/cable", cookies: {}, headers: {})
          connection = self.class.connection_class.allocate
          connection.singleton_class.include(ConnectionStub)
          connection.send(:initialize, path, cookies, headers)
          connection.connect if connection.respond_to?(:connect)

          # Only set instance variable if connected successfully
          @connection = connection
        end

        # Disconnect the connection under test (i.e. calls #disconnect)
        def disconnect
          raise "Must be connected!" if connection.nil?

          connection.disconnect if connection.respond_to?(:disconnect)
          @connection = nil
        end
      end

      include Behavior
    end
  end
end
