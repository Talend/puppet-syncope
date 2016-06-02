require 'spec_helper_acceptance'

describe 'syncope' do


  context 'with default parameters' do
    pp = <<-EOS
    class {'::syncope':
      manage_repos => true,
      repo_class   => 'syncope::tic_repositories'
    }
    EOS

    it 'behaves like idempotent resource' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_failures => true)
    end
  end

end

