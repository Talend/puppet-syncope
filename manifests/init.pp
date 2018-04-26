class syncope (

  $catalina_base              = $syncope::params::catalina_base,
  $application_path           = $syncope::params::application_path,
  $postgres_username          = $syncope::params::postgres_username,
  $postgres_password          = $syncope::params::postgres_password,
  $postgres_host              = $syncope::params::postgres_host,
  $postgres_port              = $syncope::params::postgres_port,
  $postgres_db_name           = $syncope::params::postgres_db_name,
  $admin_password             = $syncope::params::admin_password,
  $tomcat_install_from_source = $syncope::params::tomcat_install_from_source,
  $syncope_version            = $syncope::params::syncope_version,
  $syncope_console_version    = $syncope::params::syncope_console_version,
  $sts_version                = $syncope::params::sts_version,
  $java_opts                  = $syncope::params::java_opts,
  $tomcat_version             = '8',
  $manage_repos               = false,
  $repo_class                 = undef,
  $service_ensure             = running,
  $ams_security_version       = $syncope::params::ams_security_version,
  $ams_security_db_host       = $syncope::params::ams_security_db_host,
  $ams_security_db_name       = $syncope::params::ams_security_db_name,
  $ams_security_db_user       = $syncope::params::ams_security_db_user,
  $ams_security_db_pass       = $syncope::params::ams_security_db_pass,
  $tpsvc_crypto_url           = $syncope::params::tpsvc_crypto_url,

) inherits syncope::params {

  $tomcat_source_url = $tomcat_version ? {
    '7'     => 'http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.69/bin/apache-tomcat-7.0.69.tar.gz',
    default => 'http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.2/bin/apache-tomcat-8.5.2.tar.gz'
  }

  if $manage_repos {
    if $repo_class == undef {
      fail('If manage repo is set to true, "repo_class" must provided')
    } else {
      require $repo_class
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
