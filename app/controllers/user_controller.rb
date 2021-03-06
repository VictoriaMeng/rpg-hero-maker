
class UserController < ApplicationController

  get '/signup' do
    if logged_in?
      redirect "/users/#{session[:id]}"
    else
      erb :'users/signup'
    end
  end

  get '/users/:id' do
    if correct_user?
      @user = User.find(session[:id])
      erb :'users/show'
    else
      flash[:error] = "Error: You can only view your user details when logged in."
      redirect "/login"
    end
  end

  get '/login' do
    if logged_in?
      redirect "/users/#{session[:id]}"
    else
      erb :'users/login'
    end
  end

  post '/signup' do
    if blank_values?(params)
      flash[:error] = "Error: Please fill in all fields."
      redirect "/signup"
    elsif user_exists?
      flash[:error] = "User/Email exists. Please login or choose different user details."
      redirect "/signup"
    else
      @user = User.create(params)
      session[:id] = @user.id
      redirect "/users/#{@user.id}"
    end
  end

  post '/login' do
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      session[:id] = user.id
      redirect "/users/#{user.id}"
    else
      flash[:error] = "Error: Incorrect login details"
      redirect "/login"
    end
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  helpers do
    def correct_user?
      session[:id] == params[:id].to_i
    end

    def user_exists?
      username_exists? || email_exists?
    end

    def username_exists?
      User.where("lower(username) = ?", params[:username].downcase).exists?
    end

    def email_exists?
      User.where("lower(email) = ?", params[:email].downcase).exists?
    end
  end
end
