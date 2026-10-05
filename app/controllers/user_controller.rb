class UserController < ApplicationController
  def show
    @user = User.find(Current.user.id)
  end
end
