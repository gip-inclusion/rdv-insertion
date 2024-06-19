module TagsHelper
  def user_tag_creation_date(tag, user)
    tag.tag_users.find { |tag_user| tag_user.user_id == user.id }
       .created_at.strftime("%d/%m/%Y")
  end
end
