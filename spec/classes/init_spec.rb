require 'spec_helper'
describe 'syncope' do

let('facts') {{:memorysize_mb => 1024,
               :operatingsystem  => 'Centos',
               :concat_basedir   => '/var/lib/puppet/concat',
               :osfamily         => 'RedHat',
               :augeasversion => '1.4.0',
               :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
}}
  
  context 'with default values for all parameters' do
   
    it { should compile }


    it { should contain_class('syncope') }
  end
end
