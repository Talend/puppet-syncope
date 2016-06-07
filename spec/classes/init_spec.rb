require 'spec_helper'

describe 'syncope' do
  let(:title) { 'profile::web::tomcat' }
  let(:node) { 'rspec.stg.test.com' }
  let(:facts) { { :operatingsystem  => 'CentOS',
                  :memorysize_mb => 1024,
                  :concat_basedir   => '/var/lib/puppet/concat',
                  :osfamily         => 'RedHat',
                  :augeasversion => '1.4.0',
                  :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
                  :kernel => 'Linux',
                  :architecture => 'x86_64',
                  :packagecloud_master_token => ENV['PACKAGECLOUD_MASTER_TOKEN']
  }}

  context 'with default params' do
    # Test if it compiles
    it { should compile }

    # Test all default params are set
    it {
      should contain_class('syncope')
      should contain_class('syncope')
      should contain_class('syncope::install')
      should contain_class('syncope::config')
      should contain_class('syncope::service')
      should contain_tomcat__instance('syncope')
    }

  end
  context 'with manage_repos set to true and repo_class unset' do
    let(:params) {{ :manage_repos => true }}
    it "should fail" do
      expect do
        catalogue
      end.to raise_error(Puppet::Error, /If manage repo is set to true, "repo_class" must provided/)
    end
  end

  context 'with manage_repos set to true and valid repo_class', :require_pkg_cloud_token => true do

    let(:params) {
      {
        :manage_repos => true,
        :repo_class  => 'syncope::tic_repositories'
      }
    }
    it { should compile }
    it { should contain_class('syncope::tic_repositories') }

  end

end
