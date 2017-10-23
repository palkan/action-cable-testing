class EchoChannel < ApplicationCable::Channel
  def subscribed
  end

  def echo(data)
    data.delete("action")
    transmit data
  end
end
