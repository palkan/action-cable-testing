module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user_id

    def connect
      self.user_id = verify_user
    end

    def disconnect
      $stdout.puts "User #{user_id} disconnected"
    end

    private

      def verify_user
        user_id = request.params[:user_id] ||
                  request.headers["x-user-id"] ||
                  cookies.signed[:user_id] ||
                  request.session[:user_id]
        reject_unauthorized_connection unless user_id.present?
        user_id
      end
  end
end
