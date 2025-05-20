class UserListUpload::Sorter
  # configuration for specific sort orders
  STATUS_ORDERS = {
    before_user_save_status: {
      # Cycle 1 (asc)
      cycle1: {
        to_create_with_errors: 1,     # To create "invalid"
        to_create_with_no_errors: 2,  # To create "valid"
        to_update_with_errors: 3,     # To update "invalid"
        to_update_with_no_errors: 4,  # To update "valid"
        up_to_date: 5                 # Up to date
      },
      # Cycle 2 (desc)
      cycle2: {
        to_update_with_errors: 1,     # To update "invalid"
        to_update_with_no_errors: 2,  # To update "valid"
        to_create_with_errors: 3,     # To create "invalid"
        to_create_with_no_errors: 4,  # To create "valid"
        up_to_date: 5                 # Up to date
      }
    }
    # other specific configurations can be added here
  }.freeze

  def self.sort(user_rows, sort_by, sort_direction)
    sort_by = sort_by.to_s

    if custom_sort?(sort_by)
      custom_sort(user_rows, sort_by, sort_direction)
    else
      default_sort(user_rows, sort_by, sort_direction)
    end
  end

  def self.custom_sort?(sort_by)
    STATUS_ORDERS.key?(sort_by.to_sym)
  end

  def self.order_for(sort_by, sort_direction)
    sort_by = sort_by.to_sym
    cycle = sort_direction == "asc" ? :cycle1 : :cycle2
    STATUS_ORDERS[sort_by][cycle]
  end

  def self.custom_sort(user_rows, sort_by, sort_direction)
    status_order = order_for(sort_by, sort_direction)

    user_rows.sort_by do |user_row|
      value = user_row.send(sort_by)
      status_order.fetch(value, 99) # 99 for unknown values
    end
  end

  def self.default_sort(user_rows, sort_by, sort_direction)
    # we place nil values at the end
    result = user_rows.sort_by do |user_row|
      value = user_row.send(sort_by)
      [value.nil? ? 1 : 0, value]
    end

    sort_direction == "desc" ? result.reverse : result
  end

  private_class_method :custom_sort?, :order_for, :custom_sort, :default_sort
end
