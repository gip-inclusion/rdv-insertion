module Users
  class RemoveTag < BaseService
    def initialize(user:, tag:)
      @user = user
      @tag = tag
    end

    def call
      @user.tags.delete(@tag)
    end
  end
end
