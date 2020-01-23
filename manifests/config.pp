class syncope::config (

  $catalina_base              = $syncope::catalina_base,
  $application_path           = $syncope::application_path,
  $postgres_password          = $syncope::postgres_password,
  $postgres_host              = $syncope::postgres_host,
  $postgres_port              = $syncope::postgres_port,
  $postgres_db_name           = $syncope::postgres_db_name,
  $admin_password             = $syncope::admin_password,
  $tomcat_version             = $syncope::tomcat_version,
  $java_opts                  = $syncope::java_opts,
  $ams_security_version       = $syncope::ams_security_version,
  $ams_security_db_host       = $syncope::ams_security_db_host,
  $ams_security_db_name       = $syncope::ams_security_db_name,
  $ams_security_db_user       = $syncope::ams_security_db_user,
  $ams_security_db_pass       = $syncope::ams_security_db_pass,
  $tpsvc_crypto_url           = $syncope::tpsvc_crypto_url,

) {

  tomcat::config::server::host { 'localhost':
    app_base              => $application_path,
    catalina_base         => $catalina_base,
    host_ensure           => 'present',
    host_name             => 'localhost',
    parent_service        => 'Catalina',
    additional_attributes => {
      'unpackWARs' => true,
      'autoDeploy' => true
    },
  }

  unless $java_opts == undef {
    tomcat::setenv::entry {'JAVA_OPTS':
      value         => $java_opts,
      catalina_home => $catalina_base
    }
  }

  $default_apps = [
    "${catalina_base}/webapps/docs",
    "${catalina_base}/webapps/examples",
    "${catalina_base}/webapps/host-manager",
    "${catalina_base}/webapps/manager",
    "${catalina_base}/webapps/ROOT",
  ]

  file {
    "${catalina_base}/logs/console.log":
      ensure => file,
      owner  => 'tomcat',
      group  => 'tomcat',
      mode   => '0664';
    $default_apps:
      ensure => absent,
      backup => false,
      force  => true
  }

  $_admin_password_sha1 = sha1($admin_password)
  $_jpa_url = "jdbc:postgresql://${postgres_host}:${postgres_port}/${postgres_db_name}"

  $user_properties_username = 'admin'
  $user_properties_password = $admin_password

  file { 'ams security link':
    ensure => link,
    force  => true,
    path   => "${application_path}/activemq-security-service",
    target => '/opt/activemq-security-service',
  } ->
  ini_setting {
    'ams_security_db_host':
      ensure  => present,
      path    => "${application_path}/activemq-security-service/WEB-INF/classes/datasource.properties",
      section => '',
      setting => 'datasource.servername',
      value   => $ams_security_db_host;
    'ams_security_db_name':
      ensure  => present,
      path    => "${application_path}/activemq-security-service/WEB-INF/classes/datasource.properties",
      section => '',
      setting => 'datasource.databasename',
      value   => $ams_security_db_name;
    'ams_security_db_user':
      ensure  => present,
      path    => "${application_path}/activemq-security-service/WEB-INF/classes/datasource.properties",
      section => '',
      setting => 'datasource.username',
      value   => $ams_security_db_user;
    'ams_security_db_pass':
      ensure  => present,
      path    => "${application_path}/activemq-security-service/WEB-INF/classes/datasource.properties",
      section => '',
      setting => 'datasource.password',
      value   => $ams_security_db_pass;
    'tpsvc_crypto_url':
      ensure  => present,
      path    => '/opt/activemq-security-service/WEB-INF/classes/org.talend.ipaas.rt.tpsvc.crypto.client.cfg',
      section => '',
      setting => 'crypto.tpsvc.service.url',
      value   => $tpsvc_crypto_url;
  }

}
