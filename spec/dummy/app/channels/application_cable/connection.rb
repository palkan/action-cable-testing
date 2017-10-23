module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user_id
  end
end
