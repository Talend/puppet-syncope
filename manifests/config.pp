class syncope::config (

  $jmx_enabled                = $syncope::jmx_enabled,
  $cluster_enable             = $syncope::cluster_enable,
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
    additional_attributes => { 'unpackWARs' => 'true', 'autoDeploy' => 'true'},
  }


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
    "${application_path}/syncope/WEB-INF/classes/content.xml":
      source  => 'puppet:///modules/syncope/WEB-INF/classes/content.xml',
      owner   => 'tomcat',
      group   => 'tomcat',
  }

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
      value   => $admin_password,
  }

  # TODO this is a tomcat setting
  if $jmx_enabled {

    tomcat::config::server::listener { 'syncope-jmx':
      catalina_base         => $catalina_base,
      listener_ensure       => present,
      class_name            => 'org.apache.catalina.mbeans.JmxRemoteLifecycleListener',
      additional_attributes => {
        'rmiRegistryPortPlatform' => '10001',
        'rmiServerPortPlatform'   => '10002',
      },
    }
  }

}
