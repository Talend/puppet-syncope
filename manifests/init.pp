# Class: syncope
# ===========================
#
# Full description of class syncope here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'syncope':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Andreas Heumaier <andreas.heumaier@nordcloud.com>
#
# Copyright
# ---------
#
# Copyright 2016 Talend, unless otherwise noted.
#
class syncope(

  $java_home = $syncope::params::java_home,
  $postgres_username = $syncope::params::postgres_username,
  $postgres_password = $syncope::params::postgres_password,
  $postgres_node = $syncope::params::postgres_node,
  $postgres_port = $syncope::params::postgres_port,
  $postgres_db_name = $syncope::params::postgres_db_name,
  $admin_password = $syncope::params::admin_password,
  $java_xmx = undef,
  $jmx_enabled = $syncope::params::jmx_enabled,
  $cluster_enable = $syncope::params::cluster_enable,
  $syncope_nodes = undef,
  $application_path= $syncope::params::application_path



) inherits syncope::params {

  validate_re($postgres_jdbc_syncope_url, $url_re, "postgres  url is not valid url. ${postgres_jdbc_syncope_url}")
  validate_bool($jmx_enabled)




  class { 'syncope::install': } ->
  class { 'syncope::config': } ~>
  class { 'syncope::service': } ->
  Class['syncope']

}