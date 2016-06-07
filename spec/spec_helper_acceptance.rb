require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'rspec/retry'

run_puppet_install_helper

# Load shared acceptance examples
base_spec_dir = Pathname.new(File.join(File.dirname(__FILE__), 'acceptance'))
Dir[base_spec_dir.join('shared/**/*.rb')].sort.each{ |f| require f }

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  c.formatter = :documentation
  hosts.each do |host|
    copy_module_to(host, :source => proj_root, :module_name => 'syncope')

    on host, puppet('module', 'install', 'puppetlabs-stdlib'), acceptable_exit_codes: [0, 1]
    on host, puppet('module', 'install', 'puppetlabs-java'), acceptable_exit_codes: [0, 1]
    on host, puppet('module', 'install', 'puppetlabs-tomcat'), acceptable_exit_codes: [0, 1]
    on host, puppet('module', 'install', 'puppetlabs-inifile'), acceptable_exit_codes: [0, 1]
    on host, puppet('module', 'install', 'puppetlabs-concat'), acceptable_exit_codes: [0, 1]
    on host, puppet('module', 'install', 'puppet-archive'), acceptable_exit_codes: [0, 1]
    on host, puppet('module', 'install', 'computology-packagecloud'), acceptable_exit_codes: [0, 1]
    on host, puppet('module', 'install', 'puppetlabs-postgresql'), acceptable_exit_codes: [0, 1]


    create_remote_file host, '/etc/facter/facts.d/packagecloud_facts.txt', "packagecloud_master_token=#{ENV['PACKAGECLOUD_MASTER_TOKEN']}", :protocol => 'rsync'
    create_remote_file host, '/etc/facter/facts.d/master_password_facts.txt', "master_password=#{ENV['PACKAGECLOUD_MASTER_TOKEN']}", :protocol => 'rsync'
    create_remote_file host, '/etc/facter/facts.d/role_facts.txt', "puppet_role=syncope", :protocol => 'rsync'
    create_remote_file host, '/var/lib/hiera/common.yaml', "syncope::tic_repositories::access_token: #{ENV['PACKAGECLOUD_MASTER_TOKEN']}", :protocol => 'rsync'
  end
end
