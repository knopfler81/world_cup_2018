require_relative 'bot_brain'

class Bot < BotBrain

  def self.retrieve_url
    rc = JSON.parse HTTP.post("https://slack.com/api/rtm.start",
        params: {token: ENV["SLACK_TOKEN"]})
    rc['url']
  end

  def self.bot_speak
    EM.run {
    ws = Faye::WebSocket::Client.new(retrieve_url)

    ws.on :open do |event|
      p [:open]
    end

    ws.on :message do |event|
      data = JSON.parse(event.data) if event && event.data
      p [:message, data]

      if data && data['type'] == 'message' && data['text'].downcase =~/\match/
        answer = BotBrain.bot_answer
        ws.send({ type: 'message', text: answer , channel: data['channel'] }.to_json)
      end
    end

    ws.on :close do |event|
      p [:close, event.code, event.reason]
      ws = nil
    end
    }
  end

end

Bot.bot_speak
