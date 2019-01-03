class UserChannel < ApplicationCable::Channel
  def subscribed
    user = User.new(params[:id])
    stream_for user
  end
end
