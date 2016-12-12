require 'telebot'
require 'pp'
require 'yaml'
require 'pry'
require_relative "lib/shugar"

# Setting ENV variables from application.yml
YAML::load_file(File.join(__dir__, 'application.yml')).each do |key, val|
  ENV[key.to_s] = val.to_s
end

staff = {}

bot = Telebot::Bot.new(ENV['TELEGRAM_TOKEN'])

bot.run do |client, message|
  markup = Telebot::ReplyKeyboardMarkup.new(
    keyboard: [
      [ "/i_m_here", "/i_ve_gone" ],
      [ "/knok_knok" ],
      [ "/try" ]
    ]
  )

  case message.text
  when /start/
    msg = "Hi! I am a demo bot that demonstrates abilities of telebot library: https://github.com/greyblake/telebot \n" \
          "You can check my source code here: https://github.com/greyblake/telebot/blob/master/examples/demo.rb \n" \
          "Please pick any command to try me out ;) \n"
    client.send_message(chat_id: message.chat.id, text: msg, reply_markup: markup)

  when /i_m_here/
    staff[message.chat.username] = { status: 'on_place', time: Time.now.strftime('%b %d %y. %H:%M') }
    client.send_message(chat_id: message.chat.id, text: "Hello, #{message.chat.username}!")

  when /i_ve_gone/
    staff[message.chat.username] = { status: 'gone', time: Time.now.strftime('%b %d. %H:%M') }
    client.send_message(chat_id: message.chat.id, text: "By, #{message.chat.username}!")

  when /knok_knok/
    client.send_message(chat_id: message.chat.id, text: "#{message.chat.username}, wait... ")
    msg = "Here is your teammates on place \n"
    staff.each do |username, user_hash|
      msg << "#{username} time: #{user_hash[:time]} \n" if user_hash[:status] == 'on_place'
    end
    msg = "No one here :(" if msg.length <= 33
    client.send_message(chat_id: message.chat.id, text: msg)

  else
    client.send_message(chat_id: message.chat.id, text: 'Unknown command')
  end
end
