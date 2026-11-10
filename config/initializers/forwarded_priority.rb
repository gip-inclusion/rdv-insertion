# Scalingo appends the client IP to X-Forwarded-For but lets a client-supplied Forwarded header through
Rack::Request.forwarded_priority = [:x_forwarded]
