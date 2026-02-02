# Prevents blocking Sidekiq workers if external services don't respond at TCP level
# This is also usefull for this pdf generator behavior : https://github.com/gip-inclusion/pdf-generator/pull/21
Faraday.default_connection_options.request.open_timeout = 10
# Maximum time to wait for a response after connection is established
Faraday.default_connection_options.request.timeout = 30
