class syncope::config (

  $catalina_base              = $syncope::catalina_base,
  $application_path           = $syncope::application_path,
  $postgres_jdbc_syncope_url  = $syncope::postgres_jdbc_syncope_url,
  $postgres_password          = $syncope::postgres_password,
  $admin_password             = $syncope::admin_password,
) {


  tomcat::config::server::host{ 'localhost':
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


  $default_apps = [
    "${catalina_base}/webapps/docs",
    "${catalina_base}/webapps/examples",
    "${catalina_base}/webapps/host-manager",
    "${catalina_base}/webapps/manager",
    "${catalina_base}/webapps/ROOT",
  ]

  file {
    "${catalina_base}/logs/velocity.log":
      ensure  => file,
      owner   => 'tomcat',
      group   => 'tomcat',
      mode    => '0664';
    "${catalina_base}/logs/console.log":
      ensure  => file,
      owner   => 'tomcat',
      group   => 'tomcat',
      mode    => '0664';
    $default_apps:
      ensure => absent,
      force  => true
  }

  $_admin_password_sha1 = sha1($admin_password)
  ini_setting {
    'jpa_url':
      ensure  => present,
      path    => "${application_path}/syncope/WEB-INF/classes/persistence.properties",
      section => '',
      setting => 'jpa.url',
      value   => $postgres_jdbc_syncope_url;
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
}
