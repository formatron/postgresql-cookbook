actions :create
default_action :create

attribute :name, name_attribute: true, kind_of: String, required: true
attribute :password, kind_of: String, required: true
attribute :connection, kind_of: Hash, required: true
attribute :create_db, kind_of: [TrueClass, FalseClass], default: false
