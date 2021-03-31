require 'sinatra'
require 'json'
require_relative 'nudge_web_lib'

before do
  content_type :json
end

get '/:user_uuid/:book_uuid' do
  user_book_file = UserBookFile.new(user_uuid: params[:user_uuid],
                                    book_uuid: params[:book_uuid])
  puts user_book_file.contents
  user_book_file.contents.to_json
end
