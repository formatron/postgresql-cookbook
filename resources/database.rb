actions :create
default_action :create

attribute :name, name_attribute: true, kind_of: String, required: true
attribute :connection, kind_of: Hash, required: true
attribute :owner, kind_of: String
