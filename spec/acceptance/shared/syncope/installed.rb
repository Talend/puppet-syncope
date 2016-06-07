require 'spec_helper_acceptance'

shared_examples 'syncope::installed' do |parameters|

  it 'installs without errors' do
    pp = <<-EOS

    class {'java':}

    class { 'postgresql::server':
      listen_addresses   => '*',
      postgres_password  => 'testpassword'
    } ->

    postgresql::server::db { 'syncope':
      user     => 'syncope',
      password => 'syncopepassword'
    } ->

    postgresql::validate_db_connection { 'validate syncope connection':
      database_host           => 'localhost',
      database_username       => 'syncope',
      database_password       => 'syncopepassword',
      database_name           => 'syncope';
    } ->

    class {'::syncope':
      #{parameters.to_s}
    }

    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_failures => true)
  end
end
