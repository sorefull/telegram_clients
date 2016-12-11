require 'telegram/bot'
require 'yaml'
require_relative "lib/shugar"

# Setting ENV variables from application.yml
YAML::load_file(File.join(__dir__, 'application.yml')).each do |key, val|
  ENV[key.to_s] = val.to_s
end

# Telegram bot
Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN']) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.sendMessage(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
    when '/info'
      bot.api.sendMessage(chat_id: message.chat.id, text: "#{render 'lib/statics/info'}")
    when '/'
      bot.api.sendMessage(chat_id: message.chat.id, text: "#{render 'lib/statics/commands'}")
    when '/photo'
      bot.api.send_photo(chat_id: message.chat.id, photo: Faraday::UploadIO.new(__dir__ + '/lib/statics/images/view.png', 'image/png'))
    end
  end
end
