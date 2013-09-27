Typus.setup do |config|

  # Application name.
  config.admin_title = "eviterra"
  config.admin_sub_title = "`=>="

  # When mailer_sender is set, password recover is enabled. This email
  # address will be used in Admin::Mailer.
  config.mailer_sender = "webmaster@eviterra.com"

  # Define paperclip attachment styles.
  # config.file_preview = :medium
  # config.file_thumbnail = :thumb

  # Authentication: +:none+, +:http_basic+
  # Run `rails g typus:migration` if you need an advanced authentication system.
  config.authentication = :eviterra_devise
  config.user_class_name = 'Deck::User'

  # Define master_role.
  # config.master_role = "admin"

  # Define relationship.
  # config.relationship = "typus_users"

  # Define user_fk.
  #config.user_fk = "admin_user_id"
  # Define username and password for +:http_basic+ authentication
  # config.username = "admin"
  # config.password = "columbia"

  # Pagination options: These options are passed to `kaminari`.
   config.pagination = { :previous_label => "&larr; " + Typus::I18n.t("Previous"),
                         :next_label => Typus::I18n.t("Next") + " &rarr;",
                         :outer_window => 4}

end
