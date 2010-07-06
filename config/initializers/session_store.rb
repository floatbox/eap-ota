# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_trav_session',
  :secret      => 'd5d4592f048e0a8b0e5ad451704b21db20a7fd628e173fc41b95b81cf4d3cdfde950aa9e022f1ce4ed177a8fbb3857a2a788e3a789e9bc17e02e49bdf9827967'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
