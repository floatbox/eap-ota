# Typus: Admin interface for Rails applications

**Typus** is designed for a single activity:

    Trusted users editing structured content.

**Typus** doesn't try to be all the things to all the people but it's 
extensible enough to match lots of use cases.

## Key Features

- Access control by users and roles.
- CRUD and custom actions for your models on a clean interface.
- Internationalized interface.
- Extensible and overwritable templates.
- Low memory footprint.
- Show database tables.
- Easily update data.
- Create new data.
- Automatic form validation.
- Ruby 1.9 compatible.
- Sortable columns.
- Supports SQLite, MySQL, and PostgreSQL.
- Boolean filtering.
- Supports ActiveRecord.
- Search for records.
- Pagination.
- Supports Rails 2.3.
- MIT License, the same as Rails.

## Links

- [Project site and documentation](http://intraducibles.com/projects/typus)
- [Plugin source](http://github.com/fesplugas/typus)
- [Mailing list](http://groups.google.com/group/typus)
- [Bug reports](http://github.com/fesplugas/typus/issues)
- [Gems](http://gemcutter.org/gems/typus)

## Impatients to see it working?

**Step 1:** Create a Rails application using a template.

    $ rails example.com -m http://tr.im/typus_example

**Step 2:** Start the server.

    $ cd example.com && script/server

**Step 3:** Go to the admin area

    $ open http://0.0.0.0:3000/admin

## Want to see a demo working?

Demo application is hosted at Heroku (<http://typus.heroku.com/>).

Use the following credentials to log in.

    Email: user@intraducibles.com
    Password: columbia

## Installing

Install from GitHub the latest version which it's compatible with Rails 2.3.6.

    $ script/plugin install git://github.com/fesplugas/typus.git

Once `typus` is installed, run the generator to create required files 
and migrate your database.

    $ script/generate typus
    $ rake db:migrate

To create the first user, start the application server, go to 
http://0.0.0.0:3000/admin and follow the instructions.

## Namespaced Models?

If you want to be able to use `delayed_job` you need to add the following 
two lines to your `config/routes.rb` file.

    map.connect "admin/delayed/jobs/:action/:id", :controller => "admin/delayed/jobs"
    map.connect "admin/delayed/jobs/:action/:id.:format", :controller => "admin/delayed/jobs"

And then create and configure `config/typus/delayed_job.yml` and 
`config/typus/delayed_job_roles.yml` as you do with your other models.

    # config/typus/delayed_job.yml
    Delayed::Job:
      fields:
        list: ...
        form: ...
      search: ...

    # config/typus/delayed_job_roles.yml
    admin:
      Delayed::Job: all

## Support

As an experiment we encourage you to support this project by 
[donating][1] 90 &euro; if you are a developer or studio. Donations do 
allow us to spend more time working and supporting the project.

## License

Copyright &copy; 2007-2010 Francesc Esplugas Marti, released under the 
MIT license

[1]:http://intraducibles.com/projects/typus/donate