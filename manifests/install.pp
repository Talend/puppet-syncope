class syncope::install (
  $syncope_catalina_base      = $syncope::catalina_base,
  $tomcat_install_from_source = $syncope::tomcat_install_from_source,
  $tomcat_source_url          = $syncope::tomcat_source_url,
  $tomcat_version             = $syncope::tomcat_version,
  $tomcat_manage_user         = $syncope::tomcat_manage_user,
  $tomcat_manage_group        = $syncope::tomcat_manage_group,
  $tomcat_user                = $syncope::tomcat_user,
  $tomcat_group               = $syncope::tomcat_group,
  $syncope_version            = $syncope::syncope_version,
  $syncope_console_version    = $syncope::syncope_console_version,
  $sts_version                = $syncope::sts_version,
  $ams_security_version       = $syncope::ams_security_version
){

  file {'/opt/tomcat':
    ensure => 'link',
    target => $syncope_catalina_base
  }

  tomcat::instance { 'syncope':
    install_from_source => $tomcat_install_from_source,
    source_url          => $tomcat_source_url,
    catalina_base       => $syncope_catalina_base,
    java_home           => '/usr/java/default',
  } ->

  package {
    'activemq-security-service':
      ensure  => $ams_security_version,
      require => User['tomcat'];
  }

}
