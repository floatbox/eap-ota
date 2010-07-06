<h2 id="toc">Tips &amp; Tricks</h2>

This is a collection of tips and tricks which you might find useful to integrate **Typus** on your projects.

- [Splitting configuration files](#splitting_configuration_files)
- [Testing the plugin](#testing_the_plugin)
- [Single Table Inheritance](#single_table_inheritance)

<h3 id="splitting_configuration_files">Splitting configuration files</h3>

You can split your configuration files in several files so it can be easier to mantain. Files are loaded by alphabetical order.

    config/typus/001-application.yml
    config/typus/002-newsletter.yml
    config/typus/003-blog.yml
    config/typus/001-application_roles.yml
    config/typus/002-newsletter_roles.yml
    config/typus/003-blog_roles.yml

[&uarr; Back to top](#toc)

<h3 id="testing_the_plugin">Testing the plugin</h3>

**Mocha**, the library for mocking and stubbing, is required to test the plugin.

    $ sudo gem install mocha

Go to the plugins folder, install **Typus** and run the tests.

    $ cd YOUR_APPLICATION/vendor/plugins
    $ git clone git://github.com/fesplugas/typus.git
    $ cd typus
    $ rake

By default tests are be performed against a SQLite3 database in memory. You can also run tests against PostgreSQL and MySQL databases. (database name is `typus_test`)

    $ rake DB=mysql
    $ rake DB=postgresql

[&uarr; Back to top](#toc)

<h3 id="single_table_inheritance">Single Table Inheritance (STI)</h3>

Tip written by [Matthew Savage](http://amasses.net/).

Single Table Inheritance is **Typus** is relatively simple. For each model you have inheriting from a base table you need to have an entry in the `application.yml` file.

Because all models carry the same attributes its possible to create an anchored node (&NAME) in the YAML file and then merge that into the inheriting nodes with the hash merges (<<) and node reference (*NAME), as per the following example:

    Property: &PROP_BASE
      fields:
        list: address, suburb, ...(chopped)... is_active, visits, is_featured, agency, user
        form: street_number, ...(chopped)... is_under_offer
        show: id, street_number, ...(chopped)... agency, user
        options:
          selectors: property_type, type
      relationships: agency, user
      application: Property Guide

    SaleProperty:
      <<: *PROP_BASE

    RentalProperty:
      <<: *PROP_BASE

    ShareRentalProperty:
      <<: *PROP_BASE

    HolidayRentalProperty:
      <<: *PROP_BASE

This will setup the parameters which typus will look for when making the resources available.
In order to make the resources accessible you will need to add the following entries into the application_roles.yml:

    admin:
      # Property not listed which means that it isn't shown.
      SaleProperty: create, read, update, delete
      RentalProperty: create, read, update, delete
      HolidayRentalProperty: create, read, update, delete
      ShareRentalProperty: create, read, update, delete

In addition to this the controller class files also need to be created in the app/controllers/admin directory 
(e.g. `sale_property_controller.rb`, which is class `class Admin::SalePropertiesController < Admin::MasterController`)

Once this is done, restart your Rails application and visit the admin route - the new STI tables should now be available.

[&uarr; Back to top](#toc)
