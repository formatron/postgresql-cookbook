def whyrun_supported?
  true
end

use_inline_resources

def psql_command(connection)
  host = connection[:host]
  port = connection[:port]
  username = connection[:username]
  password = connection[:password]
  "PGPASSWORD=\"#{password}\" psql -U #{username} -h #{host} -p #{port} -t -d postgres"
end

def not_present?(name, connection)
  exists_command = Mixlib::ShellOut.new(
    "#{psql_command connection} -c \"SELECT 1 FROM pg_roles WHERE rolname='#{name}'\"",
  )
  exists_command.run_command
  exists_command.error!
  exists_command.stdout.match(/1/).nil?
end

def create(name, password, create_db, connection)
  create_db_clause = create_db ? ' CREATEDB' : ' NOCREATEDB'
  insert_command = Mixlib::ShellOut.new(
    "#{psql_command connection} -c \"CREATE USER #{name} WITH#{create_db_clause} PASSWORD '#{password}'\"",
  )
  insert_command.run_command
  insert_command.error!
end

def password_incorrect?(name, password, connection)
  user_connection = connection.dup
  user_connection[:username] = name
  user_connection[:password] = password
  verify_command = Mixlib::ShellOut.new(
    "#{psql_command user_connection} -l"
  )
  verify_command.run_command
  verify_command.error?
end

def update_password(name, password, connection)
  update_command = Mixlib::ShellOut.new(
    "#{psql_command connection} -c \"ALTER ROLE #{name} WITH PASSWORD '#{password}'\"",
  )
  update_command.run_command
  update_command.error!
end

def create_db_incorrect?(name, create_db, connection)
  create_db_regex = create_db ? /^\s*t\s*$/ : /^\s*f\s*$/
  create_db_query_command = Mixlib::ShellOut.new(
    "#{psql_command connection} -c \"SELECT rolcreatedb FROM pg_roles WHERE rolname='#{name}'\""
  )
  create_db_query_command.run_command
  create_db_query_command.error!
  create_db_query_command.stdout.match(create_db_regex).nil?
end

def update_create_db(name, create_db, connection)
  create_db_clause = create_db ? ' CREATEDB' : ' NOCREATEDB'
  update_command = Mixlib::ShellOut.new(
    "#{psql_command connection} -c \"ALTER ROLE #{name} WITH#{create_db_clause}\"",
  )
  update_command.run_command
  update_command.error!
end

action :create do
  connection = new_resource.connection
  name = new_resource.name
  password = new_resource.password
  create_db = new_resource.create_db
  if not_present? name, connection
    create name, password, create_db, connection
    new_resource.updated_by_last_action true
  else
    if password_incorrect? name, password, connection
      update_password name, password, connection
      new_resource.updated_by_last_action true
    end
    if create_db_incorrect? name, create_db, connection
      update_create_db name, create_db, connection
      new_resource.updated_by_last_action true
    end
  end
end
