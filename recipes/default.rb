password = node['formatron_postgresql']['postgres_password']

package 'postgresql'
package 'postgresql-contrib'

execute "psql -d postgres -c \"ALTER USER postgres WITH PASSWORD '#{password}';\"" do
  user 'postgres'
  not_if "PGPASSWORD='#{password}' psql -h localhost -U postgres -d postgres -c '\\l'"
end

service 'postgresql' do
  supports status: true, restart: true, reload: true
  action [ :enable, :start ]
end
