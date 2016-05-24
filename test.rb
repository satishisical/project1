require 'sinatra'
require 'haml'
require 'pry'
require 'sinatra/flash'
require 'sequel'
require 'bcrypt'


enable :sessions


DB = Sequel.connect('mysql://root:satyaisical@localhost/test_db')

Sequel::Model.plugin :validation_helpers

class User < Sequel::Model(:users)
  unrestrict_primary_key
  def validate
    super
    validates_unique(:email_ID)
  end
  
end

get '/home' do
  haml :home
end

get '/index' do
  haml :index
end

post '/home' do
  @user = User[params[:user]]
  @username = @user.name
  if  BCrypt::Password.new(@user.password) == params[:pass]
    session[:user] = params[:user]
    redirect '/index'
  else
  	flash[:error] = "Either of userId or password was wrong."
    redirect '/home'
  end
end

post '/reg' do
  haml :registration
end

get '/reg' do
  haml :registration
end

post '/registration' do
  if User.new(:email_ID =>params[:email_ID]).valid?
    params[:password] = BCrypt::Password.create(params[:password])
    User.create(params)
    session[:user] = params[:user]
    redirect '/home'  
    
  else
    flash[:error] = "Email ID already exists"
    redirect '/reg'
  end
end

def login?
  if session[:user].nil?
    return false
  else
    return true
  end
end


def user
  return session[:user]
end


get "/logout" do
  session[:user] = nil
  redirect "/home"
end
