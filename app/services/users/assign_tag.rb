module Users
  class AssignTag < BaseService
    def initialize(user:, tag:)
      @user = user
      @tag = tag
    end

    def call
      @user.tags << @tag
    end
  end
end
