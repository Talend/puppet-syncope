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

  $catalina_base              = $syncope::params::catalina_base,
  $application_path           = $syncope::params::application_path,
  $postgres_username          = $syncope::params::postgres_username,
  $postgres_password          = $syncope::params::postgres_password,
  $postgres_node              = $syncope::params::postgres_node,
  $postgres_port              = $syncope::params::postgres_port,
  $postgres_db_name           = $syncope::params::postgres_db_name,
  $admin_password             = $syncope::params::admin_password,
  $tomcat_install_from_source = $syncope::params::tomcat_install_from_source,
  $tomcat_source_url          = $syncope::params::tomcat_source_url,
  $tomcat_manage_user         = $syncope::params::tomcat_manage_user,
  $tomcat_manage_group        = $syncope::params::tomcat_manage_group,
  $tomcat_user                = $syncope::params::tomcat_user,
  $tomcat_group               = $syncope::params::tomcat_group,
  $tomcat_version             = '8',
  $manage_repos               = false,
  $repo_class                 = undef

) inherits syncope::params {

  if $manage_repos {
    if $repo_class == undef {
      fail('If manage repo is set to true, "repo_class" must provided')
    } else {
      include $repo_class
      Class[$repo_class] -> Class['Syncope::Install']
    }
  }

  anchor { 'syncope::begin': }
  anchor { 'syncope::end': }

  class { 'syncope::install': }
  class { 'syncope::config': }
  class { 'syncope::service': }

  Anchor['syncope::begin'] ->
    Class['syncope::install'] ->
    Class['syncope::config'] ~>
    Class['syncope::service'] ->
  Anchor['syncope::end']

}
