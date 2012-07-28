module UsersHelper

  def current_user
    user_name = cookies[:user_name]
    user = User.find_by_username user_name
    if user.nil?
      return nil
    end
    return user.id
  end

end
