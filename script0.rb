require 'telegram/bot'
require 'yaml'
require_relative "lib/shugar"

# Setting ENV variables from application.yml
YAML::load_file(File.join(__dir__, 'application.yml')).each do |key, val|
  ENV[key.to_s] = val.to_s
end

markup =  Telegram::Bot::Types::ReplyKeyboardMarkup.new(
  keyboard: [
    [ "/i_m_here", "/i_ve_gone" ],
    [ "/knok_knok" ],
    [ "/link" ]  ]
)

staff = {}

# Telegram bot
Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN']) do |bot|
  bot.listen do |message|
    case message.text
    when /start/
      msg = "Hi! I am a demo bot that demonstrates abilities of telebot library: https://github.com/greyblake/telebot \n" \
            "You can check my source code here: https://github.com/greyblake/telebot/blob/master/examples/demo.rb \n" \
            "Please pick any command to try me out ;) \n"
      bot.api.sendMessage(chat_id: message.chat.id, text: msg, reply_markup: markup)

    when /i_m_here/
      staff[message.chat.username] = { status: 'on_place', time: Time.now.strftime('%b %d %y. %H:%M') }
      bot.api.sendMessage(chat_id: message.chat.id, text: "Hello, #{message.chat.username}!")

    when /i_ve_gone/
      staff[message.chat.username] = { status: 'gone', time: Time.now.strftime('%b %d. %H:%M') }
      bot.api.sendMessage(chat_id: message.chat.id, text: "By, #{message.chat.username}!")

    when /knok_knok/
      bot.api.sendMessage(chat_id: message.chat.id, text: "#{message.chat.username}, wait... ")
      msg = "Here is your teammates on place \n"
      staff.each do |username, user_hash|
        msg << "[@#{username}](https://telegram.me/#{username}) time: #{user_hash[:time]} \n" if user_hash[:status] == 'on_place'
      end
      msg = "No one here :(" if msg.length <= 33
      bot.api.sendMessage(chat_id: message.chat.id, text: msg, parse_mode: "MARKDOWN", disable_web_page_preview: true)

    when /link/
      bot.api.sendMessage(chat_id: message.chat.id, text: "Link to [@#{message.chat.username}](https://telegram.me/#{message.chat.username})", parse_mode: "MARKDOWN")

    else
      bot.api.sendMessage(chat_id: message.chat.id, text: 'Unknown command')
    end

    # case message.text
    # when '/start'
    #   bot.api.sendMessage(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
    # when '/test'
    #   bot.api.sendMessage(chat_id: message.chat.id, text: "[text](http://www.example.com/)", parse_mode: 'Markdown', reply_markup: answers)
    # when '/info'
    #   bot.api.sendMessage(chat_id: message.chat.id, text: "#{render 'lib/statics/info'}")
    # when '/'
    #   bot.api.sendMessage(chat_id: message.chat.id, text: "#{render 'lib/statics/commands'}")
    # when '/photo'
    #   bot.api.send_photo(chat_id: message.chat.id, photo: Faraday::UploadIO.new(__dir__ + '/lib/statics/images/view.png', 'image/png'))
    # end
  end
end
