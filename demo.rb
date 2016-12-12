require 'telebot'
require 'pp'
require 'yaml'
require 'pry'
require_relative "lib/shugar"

# Setting ENV variables from application.yml
YAML::load_file(File.join(__dir__, 'application.yml')).each do |key, val|
  ENV[key.to_s] = val.to_s
end

bot = Telebot::Bot.new(ENV['TELEGRAM_TOKEN'])

bot.run do |client, message|
  markup = Telebot::ReplyKeyboardMarkup.new(
    keyboard: [
      [ "/get_me", "/send_message", "/forward_message" ],
      [ "/send_photo", "/send_audio", "/send_document" ],
      [ "/send_sticker", "/send_video", "/send_location"],
      [ "/send_chat_action", "/get_user_profile_photos"]
    ]
  )

  case message.text
  when /start/
    msg = "Hi! I am a demo bot that demonstrates abilities of telebot library: https://github.com/greyblake/telebot \n" \
          "You can check my source code here: https://github.com/greyblake/telebot/blob/master/examples/demo.rb \n" \
          "Please pick any command to try me out ;) \n"
    client.send_message(chat_id: message.chat.id, text: msg, reply_markup: markup)

  when /get_me/
    user = client.get_me
    msg = "ID: #{user.id}\n"
    msg << "First name: #{user.first_name}\n"
    msg << "Last name: #{user.last_name}\n"
    msg << "Username: #{user.username}"
    client.send_message(chat_id: message.chat.id, text: msg)

  when /send_message/
    client.send_message(chat_id: message.chat.id, text: "Hello, man! What's going on?")

  when /forward_message/
    client.forward_message(chat_id: message.chat.id, from_chat_id: message.chat.id, message_id: message.message_id)

  when /send_photo/
    file = Telebot::InputFile.new(fixture("images/view.png"), 'image/png')
    client.send_photo(chat_id: message.chat.id, photo: file)

  when /send_audio/
    client.send_message(chat_id: message.chat.id, text: "Let me say 'Hi' in Esperanto.")
    file = Telebot::InputFile.new(fixture("audio/Intro.mp3"))
    client.send_audio(chat_id: message.chat.id, audio: file)

  when /send_document/
    file = Telebot::InputFile.new(__FILE__)
    client.send_document(chat_id: message.chat.id, document: file)

  when /send_sticker/
    file = Telebot::InputFile.new(fixture("images/zamenhof_sticker.webp"))
    client.send_sticker(chat_id: message.chat.id, sticker: file)

  when /send_video/
    client.send_message(chat_id: message.chat.id, text: "My anaconda don't!")
    file = Telebot::InputFile.new(fixture("video/anaconda.mp4"))
    client.send_video(chat_id: message.chat.id, video: file)

  when /send_location/
    client.send_location(chat_id: message.chat.id, latitude: 53.131684, longitude: 23.169556)

  when /pry/
    binding.pry
    client.send_message(chat_id: message.chat.id, text: "Thanks for pry.")

  when /send_chat_action/
    client.send_message(chat_id: message.chat.id, text: "Check my status, I am typing")
    client.send_chat_action(chat_id: message.chat.id, action: :typing)
    sleep 3
    client.send_message(chat_id: message.chat.id, text: "Done")

  when /get_user_profile_photos/
    photos = client.get_user_profile_photos(user_id: message.from.id)
    if photos.total_count > 0
      client.send_message(chat_id: message.chat.id, text: "Look at yourself!")
      photo = photos.photos.first
      photo_size = photo.first
      client.send_photo(chat_id: message.chat.id, photo: photo_size.file_id)
    else
      client.send_message(chat_id: message.chat.id, text: "Your profile has no photos")
    end

  else

    client.send_message(chat_id: message.chat.id, text: 'Unknown command')
  end
end
