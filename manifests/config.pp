class syncope::config (

  $catalina_base              = $syncope::catalina_base,
  $application_path           = $syncope::application_path,
  $postgres_password          = $syncope::postgres_password,
  $postgres_host              = $syncope::postgres_host,
  $postgres_port              = $syncope::postgres_port,
  $postgres_db_name           = $syncope::postgres_db_name,
  $admin_password             = $syncope::admin_password,
  $tomcat_version             = $syncope::tomcat_version,
  $java_opts                  = $syncope::java_opts
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

  augeas {
    'set syncope sts claimsHandler password':
      lens    => 'Xml.lns',
      incl    => '/opt/tomcat/webapps/sts/WEB-INF/beans.xml',
      context => '/files/opt/tomcat/webapps/sts/WEB-INF/beans.xml/beans',
      changes => [
      "set bean[#attribute/id='claimsHandler']/property[#attribute/name='password']/#attribute/value ${admin_password}"
      ];
    'disable jpa caches':
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
}
