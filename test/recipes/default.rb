include_recipe 'apt::default'

node.override['formatron_postgresql']['postgres_password'] = 'hello'
include_recipe 'formatron_postgresql::default'


formatron_postgresql_user 'myuser' do
  connection(
    host: 'localhost',
    port: 5432,
    username: 'postgres',
    password: 'hello'
  )
  password 'password'
  create_db true
end

formatron_postgresql_database 'mydb' do
  connection(
    host: 'localhost',
    port: 5432,
    username: 'myuser',
    password: 'password'
  )
end
