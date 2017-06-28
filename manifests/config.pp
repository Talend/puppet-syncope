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
  $ams_security_db_host       = $syncope::ams_security_db_host,
  $ams_security_db_name       = $syncope::ams_security_db_name,
  $ams_security_db_user       = $syncope::ams_security_db_user,
  $ams_security_db_pass       = $syncope::ams_security_db_pass,
  $crypto_url                 = $syncope::crypto_url,
  $crypto_user                = $syncope::crypto_user,
  $crypto_pass                = $syncope::crypto_pass,

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
    "${catalina_base}/logs/velocity.log":
      ensure => file,
      owner  => 'tomcat',
      group  => 'tomcat',
      mode   => '0664';
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

  ini_setting {
    'jpa_url':
      ensure  => present,
      path    => "${application_path}/syncope/WEB-INF/classes/persistence.properties",
      section => '',
      setting => 'jpa.url',
      value   => $_jpa_url;

    'pgpassword':
      ensure  => present,
      path    => "${application_path}/syncope/WEB-INF/classes/persistence.properties",
      section => '',
      setting => 'jpa.password',
      value   => $postgres_password;

    'admin_password':
      ensure  => present,
      path    => "${application_path}/syncope/WEB-INF/classes/security.properties",
      section => '',
      setting => 'adminPassword',
      value   => $_admin_password_sha1,
  }

  if size($admin_password) > 0 {
    augeas { 'set syncope sts claimsHandler password':
      lens    => 'Xml.lns',
      incl    => '/opt/tomcat/webapps/sts/WEB-INF/beans.xml',
      context => '/files/opt/tomcat/webapps/sts/WEB-INF/beans.xml/beans',
      changes => [
        "set bean[#attribute/id='claimsHandler']/property[#attribute/name='password']/#attribute/value ${admin_password}"
      ]
    }
  }

  augeas { 'disable jpa caches':
    lens    => 'Xml.lns',
    incl    => '/opt/apache-tomcat/syncope/webapps/syncope/WEB-INF/classes/persistenceContextEMFactory.xml',
    changes => [
      "set beans/bean[#attribute/id ='entityManagerFactory']\
/property[#attribute/name = 'jpaPropertyMap']\
/map/entry[#attribute/key = 'openjpa.DataCache']/#attribute/value 'false'",
      "set beans/bean[#attribute/id = 'entityManagerFactory']\
/property[#attribute/name = 'jpaPropertyMap']\
/map/entry[#attribute/key = 'openjpa.QueryCache']\
/#attribute/value 'false'",
      "rm beans/bean[#attribute/id = 'entityManagerFactory']\
/property[#attribute/name = 'jpaPropertyMap']\
/map/entry[#attribute/key = 'openjpa.RemoteCommitProvider']"
    ]
  }

  $user_properties_username = 'admin'
  $user_properties_password = $admin_password
  file { '/opt/tomcat/webapps/sts/WEB-INF/classes/user.properties':
    content => template('syncope/user.properties.erb'),
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0660'
  }

  ini_setting {
    'ipaas_crypto_url':
      ensure  => present,
      path    => "${application_path}/activemq-security-service/WEB-INF/classes/org.talend.ipaas.rt.crypto.client.cfg",
      section => '',
      setting => 'crypto.service.url',
      value   => $crypto_url;
    'ipaas_crypto_user':
      ensure  => present,
      path    => "${application_path}/activemq-security-service/WEB-INF/classes/org.talend.ipaas.rt.crypto.client.cfg",
      section => '',
      setting => 'crypto.service.username',
      value   => $crypto_user;
    'ipaas_crypto_pass':
      ensure  => present,
      path    => "${application_path}/activemq-security-service/WEB-INF/classes/org.talend.ipaas.rt.crypto.client.cfg",
      section => '',
      setting => 'crypto.service.password',
      value   => $crypto_pass;
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
    'ams_security_migration_18_db_url':
      ensure  => present,
      path    => "/opt/activemq-security-migration-v18to182/migration.properties",
      section => '',
      setting => 'postgresAddress',
      value   => "jdbc:postgresql://${ams_security_db_host}:5432/${ams_security_db_name}";
    'ams_security_migration_18_db_user':
      ensure  => present,
      path    => "/opt/activemq-security-migration-v18to182/migration.properties",
      section => '',
      setting => 'postgresUsername',
      value   => $ams_security_db_user;
    'ams_security_migration_18_db_pass':
      ensure  => present,
      path    => "/opt/activemq-security-migration-v18to182/migration.properties",
      section => '',
      setting => 'postgresPassword',
      value   => $ams_security_db_pass;
    'ams_security_migration_18_crypto_url':
      ensure  => present,
      path    => "/opt/activemq-security-migration-v18to182/migration.properties",
      section => '',
      setting => 'crypto.service.url',
      value   => $crypto_url;
    'ams_security_migration_18_crypto_user':
      ensure  => present,
      path    => "/opt/activemq-security-migration-v18to182/migration.properties",
      section => '',
      setting => 'crypto.service.username',
      value   => $crypto_user;
    'ams_security_migration_18_crypto_pass':
      ensure  => present,
      path    => "/opt/activemq-security-migration-v18to182/migration.properties",
      section => '',
      setting => 'crypto.service.password',
      value   => $crypto_pass;
    'ams_security_migration_20_db_url':
      ensure  => present,
      path    => "/opt/activemq-security-migration-v18to20/migration.properties",
      section => '',
      setting => 'postgresAddress',
      value   => "jdbc:postgresql://${ams_security_db_host}:5432/${ams_security_db_name}";
    'ams_security_migration_20_db_user':
      ensure  => present,
      path    => "/opt/activemq-security-migration-v18to20/migration.properties",
      section => '',
      setting => 'postgresUsername',
      value   => $ams_security_db_user;
    'ams_security_migration_20_db_pass':
      ensure  => present,
      path    => "/opt/activemq-security-migration-v18to20/migration.properties",
      section => '',
      setting => 'postgresPassword',
      value   => $ams_security_db_pass;
    'ams_security_migration_20_crypto_url':
      ensure  => present,
      path    => "/opt/activemq-security-migration-v18to20/migration.properties",
      section => '',
      setting => 'crypto.tpsvc.service.url',
      value   => $crypto_url;
  }
}
