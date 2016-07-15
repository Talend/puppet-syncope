class {'java':
} ->
packagecloud::repo { 'talend/other':
  type         => 'rpm',
  master_token => $packagecloud_master_token
} ->
class { 'postgresql::server':
  listen_addresses   => '*',
  postgres_password  => 'testpassword'
} ->
postgresql::server::db { 'syncope':
  user     => 'syncope',
  password => 'syncopepassword'
} ->
postgresql::validate_db_connection { 'validate syncope connection':
  database_host     => 'localhost',
  database_username => 'syncope',
  database_password => 'syncopepassword',
  database_name     => 'syncope';
} ->
class { '::syncope':
  manage_repos      => false,
  postgres_username => 'syncope',
  postgres_password => 'syncopepassword',
  postgres_host     => 'localhost',
  postgres_db_name  => 'syncope',
  admin_password    => 'testpassword'
}
