Rails.application.config.after_initialize do
  # Monkey patch for the `with_advisory_lock` gem.
  #
  # By default, the gem adds a random `AS` alias to advisory lock SQL queries to prevent Rails caching.
  # (see https://github.com/ClosureTree/with_advisory_lock/blob/40f9af3a19cbe3fc15b1a891a5e764d41e0089ad/lib/with_advisory_lock/postgresql_advisory.rb#L108).

  # This makes the queries harder to identify and group in Skylight because the alias is random.
  #
  # However, this mechanism is old and we can use the `uncached` method to prevent Rails caching instead.
  # (see https://github.com/ClosureTree/with_advisory_lock/issues/48)
  # So this patch removes the alias and wraps the SQL call in `uncached`
  # so Skylight can capture clean, consistent SQL traces like:
  #   SELECT pg_try_advisory_lock(123,456) /* lock_name */

  # ⚠️ WARNING: This patch relies on private methods of the gem.
  # It may break things if the gem changes even if it's tested, so watch for version updates!

  expected_gem_version = Gem::Version.new("7.0.1")
  actual_gem_version = Gem.loaded_specs["with_advisory_lock"]&.version

  if actual_gem_version != expected_gem_version
    error_message = "\n[with_advisory_lock_patch] ⚠️ Expected with_advisory_lock version #{expected_gem_version}, " \
                    "but got #{actual_gem_version}.\n" \
                    "Please review the patch and update the expected version if it works as expected.\n"
    Rails.env.local? ? raise(error_message) : Rails.logger.error(error_message)
  end

  # rubocop:disable Lint/ConstantDefinitionInBlock
  module WithAdvisoryLock::PostgreSQLAdvisory
    private

    def execute_advisory(function, lock_keys, lock_name)
      uncached { select_value(prepare_sql(function, lock_keys, lock_name)) }.in?(LOCK_RESULT_VALUES)
    end

    def prepare_sql(function, lock_keys, lock_name)
      comment = lock_name.to_s.gsub(%r{(/\*)|(\*/)}, "--")
      "SELECT #{function}(#{lock_keys.join(',')}) /* #{comment} */"
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock
end
