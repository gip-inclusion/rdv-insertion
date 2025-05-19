# Uploading more than 300 users in a single FormData upload results
# in a 400 error because of the key space limit of Rack.
# The default limit is arbitrary (4096) and we can confidently
# raise it a bit.
#
# Setting it to 10_000 should allow for ~600 users to be uploaded
# in a single upload why still be low enough to cause issues
Rack::Utils.key_space_limit = 10_000
