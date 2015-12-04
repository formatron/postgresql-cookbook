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
    "#{psql_command connection} -c \"SELECT 1 FROM pg_database WHERE datname='#{name}'\"",
  )
  exists_command.run_command
  exists_command.error!
  exists_command.stdout.match(/1/).nil?
end

def create(name, owner, connection)
  owner_clause = owner.nil? ? '' : " WITH OWNER #{owner}"
  insert_command = Mixlib::ShellOut.new(
    "#{psql_command connection} -c \"CREATE DATABASE #{name}#{owner_clause}\"",
  )
  insert_command.run_command
  insert_command.error!
end

def not_owned_by?(name, owner, connection)
  return false if owner.nil?
  get_owner_command = Mixlib::ShellOut.new(
    "#{psql_command connection} -c \"SELECT pg_catalog.pg_get_userbyid(d.datdba) as \\\"Owner\\\" FROM pg_catalog.pg_database d WHERE d.datname = '#{name}' ORDER BY 1;\"",
  )
  get_owner_command.run_command
  get_owner_command.error!
  get_owner_command.stdout.match(/^\s*#{owner}\s*$/).nil?
end

def update(name, owner, connection)
  update_command = Mixlib::ShellOut.new(
    "#{psql_command connection} -c \"ALTER DATABASE #{name} OWNER TO #{owner}\"",
    user: 'postgres'
  )
  update_command.run_command
  update_command.error!
end

action :create do
  name = new_resource.name
  owner = new_resource.owner
  connection = new_resource.connection
  if not_present? name, connection
    create name, owner, connection
    new_resource.updated_by_last_action true
  else
    if not_owned_by? name, owner, connection
      update name, owner, connection
      new_resource.updated_by_last_action true
    end
  end
end
