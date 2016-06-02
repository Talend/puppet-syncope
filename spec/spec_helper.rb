require 'puppetlabs_spec_helper/module_spec_helper'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.hiera_config = File.join(fixture_path, 'hiera/hiera.yaml')
  c.filter_run_excluding :require_pkg_cloud_token => true unless ENV.has_key? 'PACKAGECLOUD_MASTER_TOKEN'
end
