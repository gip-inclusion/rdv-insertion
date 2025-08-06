# This is a regression test to ensure that the with_advisory_lock_patch is applied correctly
# and does not break the lock mechanism

# rubocop:disable RSpec/DescribeClass
RSpec.describe "with_advisory_lock" do
  after do
    # Ensure all DB connections are returned and locks are cleared after each test
    ActiveRecord::Base.connection_pool.clear_reloadable_connections!
  end

  # This ensures the with_advisory_lock patch does not break the lock mechanism
  it "only executes the block in one thread" do
    lock_key = "test-lock-key"
    executed = []

    t1 = Thread.new do
      # Each thread must use its own DB connection to ensure advisory locks work correctly.
      # `with_connection` also ensures connections are checked back into the pool,
      # so that locks don't persist after the test and no leaks occur.
      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.with_advisory_lock(lock_key, timeout_seconds: 0.1) do
          executed << :t1
          sleep 0.2
        end
      end
    end

    t2 = Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.with_advisory_lock(lock_key, timeout_seconds: 0.1) do
          executed << :t2
          sleep 0.2
        end
      end
    end

    [t1, t2].each(&:join)

    expect(executed.size).to eq(1)
    expect(executed).to contain_exactly(:t1).or contain_exactly(:t2)
  end

  # This ensures the with_advisory_lock patch does not generate an alias in advisory lock SQL
  it "does not generate an alias in advisory lock SQL" do
    sql = nil

    # Capture the SQL run by ActiveRecord
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_, _, _, _, payload|
      sql = payload[:sql] if payload[:sql].include?("pg_try_advisory_lock") && payload[:sql].include?("/*")
    end

    ActiveRecord::Base.with_advisory_lock("test-lock-key") { "test" }

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(sql).to be_present
    expect(sql).to include("/* test-lock-key */")
    expect(sql).not_to include(" AS ")
  end
end
# rubocop:enable RSpec/DescribeClass
