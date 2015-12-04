def whyrun_supported?
  true
end

use_inline_resources

def not_present?(name)
  exists_command = Mixlib::ShellOut.new(
    "psql -t -c \"SELECT 1 FROM pg_database WHERE datname='#{name}'\"",
    user: 'postgres'
  )
  exists_command.run_command
  exists_command.error!
  exists_command.stdout.match(/1/).nil?
end

def create(name, owner)
  insert_command = Mixlib::ShellOut.new(
    "psql -t -c \"CREATE DATABASE #{name} WITH OWNER #{owner}\"",
    user: 'postgres'
  )
  insert_command.run_command
  insert_command.error!
end

def not_owned_by?(name, owner)
  get_owner_command = Mixlib::ShellOut.new(
    "psql -t -c \"SELECT pg_catalog.pg_get_userbyid(d.datdba) as \\\"Owner\\\" FROM pg_catalog.pg_database d WHERE d.datname = '#{name}' ORDER BY 1;\"",
    user: 'postgres'
  )
  get_owner_command.run_command
  get_owner_command.error!
  get_owner_command.stdout.match(/^\s*#{owner}\s*$/).nil?
end

def update(name, owner)
  update_command = Mixlib::ShellOut.new(
    "psql -t -c \"ALTER DATABASE #{name} OWNER TO #{owner}\"",
    user: 'postgres'
  )
  update_command.run_command
  update_command.error!
end

action :create do
  name = new_resource.name
  owner = new_resource.owner
  if not_present? name
    create name, owner
    new_resource.updated_by_last_action true
  else
    if not_owned_by? name, owner
      update name, owner
      new_resource.updated_by_last_action true
    end
  end
end
