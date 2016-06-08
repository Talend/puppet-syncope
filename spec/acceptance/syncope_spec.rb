require 'spec_helper_acceptance'

describe 'syncope' do

  it_should_behave_like 'syncope::installed', "
      manage_repos      => true,
      repo_class        => 'syncope::tic_repositories',
      postgres_username => 'syncope',
      postgres_password => 'syncopepassword',
      postgres_node     => 'localhost',
      postgres_db_name  => 'syncope',
      admin_password    => 'testpassword'
  "

  it_should_behave_like 'syncope::running'

  describe command('/usr/bin/curl -v -f -X GET -u admin:testpassword http://localhost:8080/syncope/rest/roles 2>&1') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should include '<name>AUTHENTICATED</name>' }
      its(:stdout) { should include '<name>ACCOUNT_ADMIN</name>' }
  end


end

