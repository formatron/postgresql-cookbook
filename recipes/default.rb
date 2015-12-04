password = node['formatron_postgresql']['postgres_password']

package 'postgresql'
package 'postgresql-contrib'

service 'postgresql' do
  supports status: true, restart: true, reload: true
  action [ :enable, :start ]
end

execute 'Set locale and Create cluster' do
  command 'export LC_ALL=C; /usr/bin/pg_createcluster --start 9.3 main'
  action :run
  not_if { ::File.directory?('/etc/postgresql/9.3/main') }
end

execute "psql -d postgres -c \"ALTER USER postgres WITH PASSWORD '#{password}';\"" do
  user 'postgres'
  not_if "PGPASSWORD='#{password}' psql -h localhost -U postgres -d postgres -c '\\l'"
end
