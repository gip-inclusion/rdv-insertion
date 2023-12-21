module Users
  class SortList
    attr_reader :users, :params

    def initialize(users:, params:)
      @users = users
      @params = params
    end

    def perform
      if params[:users_scope] == "archived"
        archived_order
      elsif params[:users_scope] == "motif_category"
        motif_category_order
      else
        all_users_order
      end
    end

    def archived_order
      @users = users.order("archives.created_at desc")
    end

    def motif_category_order
      @users = users.select("users.*, rdv_contexts.created_at, MIN(users_organisations.created_at) AS min_created_at")
                    .order("rdv_contexts.created_at desc")
    end

    def all_users_order
      @users = users.reselect("users.*, MIN(users_organisations.created_at) AS min_created_at")
                    .group("users.id")
                    .order("min_created_at DESC")
    end
  end
end
