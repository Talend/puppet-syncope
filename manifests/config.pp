class syncope::config (

  $jmx_enabled = $syncope::jmx_enabled,
  $cluster_enable = $syncope::cluster_enable,
  $application_path = $syncope::application_path

) {


  tomcat::config::server::host{ 'localhost':
    app_base              => $application_path,
    catalina_base         => '/opt/apache-tomcat/tomcat7',
    host_ensure           => 'present',
    host_name             => 'localhost',
    parent_service        => 'Catalina',
    additional_attributes => { 'unpackWARs'=>'true', 'autoDeploy'=>'true'},
  }


  file {
    "${application_path}/logs/velocity.log":
      ensure  => file,
      owner   => 'tomcat',
      group   => 'tomcat',
      mode    => '0664';
    "${application_path}/webapps/syncope/WEB-INF/classes/content.xml":
      source  => "puppet:///modules/syncope/WEB-INF/classes/content.xml",
      owner   => 'tomcat',
      group   => 'tomcat',
      notify  => Service['tomcat'];
  }

  ini_setting {
    'jpa_url':
      ensure  => present,
      path    => "${application_path}/webapps/syncope/WEB-INF/classes/persistence.properties",
      section => '',
      setting => 'jpa.url',
      value   => $postgres_jdbc_syncope_url,
      notify  => Service['tomcat-syncope-srv'];
    'pgpassword':
      ensure  => present,
      path    => "${application_path}/webapps/syncope/WEB-INF/classes/persistence.properties",
      section => '',
      setting => 'jpa.password',
      value   => $postgres_password,
      notify  => Service['tomcat'];
    'admin_password':
      ensure  => present,
      path    => "${application_path}/webapps/syncope/WEB-INF/classes/security.properties",
      section => '',
      setting => 'adminPassword',
      value   => $admin_password,
      notify  => Service['tomcat'];
  }

  # TODO this is a tomcat setting
  if $jmx_enabled {

    tomcat::config::server::listener { 'syncope-jmx':
      catalina_base         => '/opt/apache-tomcat/tomcat7',
      listener_ensure       => present,
      class_name            => 'org.apache.catalina.mbeans.JmxRemoteLifecycleListener',
      additional_attributes => {
        'rmiRegistryPortPlatform' => '10001',
        'rmiServerPortPlatform'   => '10002',
      },
    }
  }

  if $cluster_enable == true {
    $syncope_nodes_formatted   = regsubst($syncope_nodes, ',', ';', 'G')

    $syncope_nodes_serf_args   = regsubst($syncope_nodes, ',', ' -node=', 'G')

    if empty($syncope_nodes_serf_args) == false {
      exec { 'force-serf-update':
        command  => "serf query -node=${syncope_nodes_serf_args} forcepnow && touch /var/lock/forced_syncope_pnow.lock",
        creates  => '/var/lock/forced_syncope_pnow.lock',
        provider => 'shell',
        notify   => Service['tomcat-syncope-srv'],
      } ->
      notify { "running serf query for syncope: serf query -node=${syncope_nodes_serf_args} forcepnow": }
    }

    exec { 'postgres-jar-link':
      command  => 'ln -fs ${application_path}/webapps/syncope/WEB-INF/lib/postgresql* ${application_path}/lib && touch /var/lock/postgres_jar_link.lock',
      creates  => '/var/lock/postgres_jar_link.lock',
      provider => 'shell',
      notify   => Service['tomcat-syncope-srv'],
    }

    exec { 'dbcp-jar-link':
      command  => 'ln -fs /usr/share/java/tomcat/commons-dbcp.jar ${application_path}/lib && touch /var/lock/dbcp-jar-link.lock',
      creates  => '/var/lock/dbcp-jar-link.lock',
      provider => 'shell',
      notify   => Service['tomcat-syncope-srv'],
    }

    file { '${application_path}/conf/context.xml':
      owner   => 'tomcat',
      group   => 'adm',
      mode    => '0644',
      content => template('syncope${application_path}/conf/context.xml.erb'),
      notify  => Service['tomcat-syncope-srv'],
    }

    file_line { 'uncomment-resource-ref-begin':
      ensure => 'present',
      path   => '${application_path}/webapps/syncope/WEB-INF/web.xml',
      match  => '.*<!--<resource-ref>.*',
      line   => '<resource-ref>',
      notify => Service['tomcat-syncope-srv'],
    }

    file_line { 'uncomment-resource-ref-end':
      ensure => 'present',
      path   => '${application_path}/webapps/syncope/WEB-INF/web.xml',
      match  => '.*</resource-ref>-->.*',
      line   => '</resource-ref>',
      notify => Service['tomcat-syncope-srv'],
    }

    file_line { 'replace-presistence-context':
      ensure => 'present',
      path   => '${application_path}/webapps/syncope/WEB-INF/classes/persistenceContextEMFactory.xml',
      match  => '.*<entry key="openjpa.RemoteCommitProvider" value=.*',
      line   => "<entry key=\"openjpa.RemoteCommitProvider\" value=\"tcp(Addresses=${syncope_nodes_formatted})\"/>",
      after  => '<entry key="openjpa.QueryCache" value="true"/>',
      notify => Service['tomcat-syncope-srv'],
    }

  }
}
