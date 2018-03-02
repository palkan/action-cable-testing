class ChatChannel < ApplicationCable::Channel
  periodically every: 5.seconds do
    transmit action: :now, time: Time.now
  end

  def subscribed
    reject unless user_id.present?

    @room_id = params[:room_id]

    stream_from "chat_#{@room_id}" if @room_id.present?
  end

  def speak(data)
    ActionCable.server.broadcast(
      "chat_#{@room_id}", text: data['message'], user_id: user_id
    )
  end

  def leave
    @room_id = nil
    stop_all_streams
  end
end
