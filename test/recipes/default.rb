include_recipe 'apt::default'

node.override['formatron_postgresql']['postgres_password'] = 'hello'
include_recipe 'formatron_postgresql::default'

formatron_postgresql_user 'myuser' do
  password 'password'
end

formatron_postgresql_database 'mydb' do
  owner 'myuser'
end
