def whyrun_supported?
  true
end

use_inline_resources

def not_present?(name)
  exists_command = Mixlib::ShellOut.new(
    "psql -t -c \"SELECT 1 FROM pg_roles WHERE rolname='#{name}'\"",
    user: 'postgres'
  )
  exists_command.run_command
  exists_command.error!
  exists_command.stdout.match(/1/).nil?
end

def create(name, password)
  insert_command = Mixlib::ShellOut.new(
    "psql -t -c \"CREATE USER #{name} WITH PASSWORD '#{password}'\"",
    user: 'postgres'
  )
  insert_command.run_command
  insert_command.error!
end

def password_incorrect?(name, password)
  verify_command = Mixlib::ShellOut.new(
    "PGPASSWORD=\"#{password}\" psql -h localhost -U #{name} -t -l"
  )
  verify_command.run_command
  verify_command.error?
end

def update(name, password)
  update_command = Mixlib::ShellOut.new(
    "psql -t -c \"ALTER ROLE #{name} WITH PASSWORD '#{password}'\"",
    user: 'postgres'
  )
  update_command.run_command
  update_command.error!
end

action :create do
  name = new_resource.name
  password = new_resource.password
  if not_present? name
    create name, password
    new_resource.updated_by_last_action true
  else
    if password_incorrect? name, password
      update name, password
      new_resource.updated_by_last_action true
    end
  end
end
