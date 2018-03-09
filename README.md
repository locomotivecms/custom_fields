[CustomFields]
==============

[![Travis CI Status][Travis CI Status]][Travis CI]
[![Gemnasium Status][Gemnasium Status]][Gemnasium]

Manage custom fields to a Mongoid document or a collection. This module is one of the core features we implemented in
our custom CMS, named LocomotiveCMS. Basically, its aim is to provide to editors a way to manage extra fields to a
Mongoid document through, for instance, a web UI.

The main goals:

* Offering a very secure way to add, edit and delete extra fields to a Mongoid document.
* Scoping the modifications added to a Mongoid document, so that other documents of the same class won't be updated.

Requirements
------------

* MongoDB 3.x
* Mongoid 6.x
* ActiveSupport 5.2.x

Examples
--------

### On a `has_many` relationship

```ruby
class Company
  include CustomFields::Source

  has_many :employees

  custom_fields_for :employees
end

class Employee
  include CustomFields::Target

  field :name, String

  belongs_to :company, inverse_of: :employees
end

company = Company.new
company.employees_custom_fields.build label: 'His/her position', name: 'position', type: 'string', required: true

company.save

company.employees.build name: 'Michael Scott', position: 'Regional manager'

another_company = Company.new
employee = another_company.employees.build
employee.position # Returns a `not defined method` error
```

### On the class itself

**IN PROGRESS**

```ruby
class Company
  custom_fields_for_itself
end

company = Company.new
company.self_metadata_custom_fields.build label: 'Shipping Address', name: 'address', type: 'text'

company.save

company.self_metadata.address = '700 S Laflin, 60607 Chicago'

another_company = Company.new
other_company.self_metadata.address # Returns a `not defined method` error
```

Development
-----------

### Run specs

Run `rspec` or `rake`.

### Test Coverage

Run `COVERAGE=true rspec` or `COVERAGE=true rake`.

Contact
-------

Feel free to contact me at did at locomotivecms dot com.

License
-------

Copyright (c) 2018 NoCoffee, released under the [MIT License (MIT)], see [MIT-LICENSE].

[CustomFields]: https://github.com/locomotivecms/custom_fields "Custom fields extension for Mongoid."
[Gemnasium]: https://gemnasium.com/locomotivecms/custom_fields "CustomFields at Gemnasium"
[Gemnasium Status]: https://img.shields.io/gemnasium/locomotivecms/custom_fields.svg?style=flat "Gemnasium Status"
[LICENSE]: https://raw.githubusercontent.com/locomotivecms/custom_fields/master/LICENSE "License"
[MIT License (MIT)]: http://opensource.org/licenses/MIT "The MIT License (MIT)"
[Travis CI]: https://travis-ci.org/locomotivecms/custom_fields "CustomFields at Travis CI"
[Travis CI Status]: https://img.shields.io/travis/locomotivecms/custom_fields.svg?style=flat "Travis CI Status"
