require 'sinatra'
require_relative 'nudge_web_api'
require 'json'

before do
  content_type :json
end

get '/:user_uuid/:book_uuid' do
  user_book_file_contents(user_uuid: params[:user_uuid],
                          book_uuid: params[:book_uuid])
end
