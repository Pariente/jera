class AddDefaultPictureToUsers < ActiveRecord::Migration
  def change
    change_column_default :users, :picture, "/images/default_user_picture.png"
    users = User.where(picture: "")
    users.each do |u|
      u.picture = "/images/default_user_picture.png"
      u.save
    end
  end
end
