require 'spec_helper_acceptance'

describe 'syncope' do

  it_should_behave_like 'syncope::installed', "
      manage_repos      => true,
      repo_class        => 'syncope::tic_repositories',
      postgres_username => 'syncope',
      postgres_password => 'syncopepassword',
      postgres_node     => 'localhost',
      postgres_db_name  => 'syncope'
  "

  it_should_behave_like 'syncope::running'

  xit 'should have role AUTHENTICATED' do
  end

  xit 'should have role ACCOUNT_ADMIN' do
  end

end

