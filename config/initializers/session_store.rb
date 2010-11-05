# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tripdb_session',
  :secret      => '121d587045b3b0e36f8966ba90474292a62f5a4d64cf731871b17770f6a3eacdbcf47d2c96ec50424276d89954ee515c4e80b7a2e5c913d0a3d2d2de340b42f6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
