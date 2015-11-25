include_recipe 'apt::default'

node.override['formatron_postgresql']['postgres_password'] = 'hello'
include_recipe 'formatron_postgresql::default'
