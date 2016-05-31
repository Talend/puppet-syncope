require 'spec_helper'

describe 'syncope' do

  let(:title) { 'profile::web::tomcat' }
  let(:node) { 'rspec.stg.test.com' }

  describe 'building  on Centos' do
    let(:facts) { { :operatingsystem  => 'Centos',
                    :memorysize_mb => 1024,
                    :concat_basedir   => '/var/lib/puppet/concat',
                    :osfamily         => 'RedHat',
                    :augeasversion => '1.4.0',
                    :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
                    :kernel => 'Linux',
                    :architecture => 'x86_64'
    }}

    # Test if it compiles
    it { should compile }
    it { should have_resource_count(38)}

    # Test all default params are set
    it {
      should contain_java__oracle('jdk8')
      should contain_class('syncope')
      should contain_class('syncope')
      should contain_class('syncope::install')
      should contain_class('syncope::config')
      should contain_class('syncope::service')
      should contain_tomcat__instance('syncope')

    }

  end
end
