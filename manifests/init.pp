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
  $java_homei = '/usr/',
  $postgres_username='syncope',
  $postgres_password = 'change_me_idiot',
  $postgres_node = 'localhost',
  $postgres_port = 5432,
  $postgres_db_name = 'syncope',
  $admin_password = 'NoNoNoNoNoNoNoNoNoNoNoNo',
  $java_xmx = undef,
  $cluster_enable = undef,
  $syncope_nodes = undef,
  $jmx_enabled = false,
) {
  $java_xmx_default = floor($::memorysize_mb * 0.70)
  $java_xmx_real = pick($java_xmx, $java_xmx_default)
  $url_re = '^(jdbc:postgresql?:\/\/)?([\da-z\.-]+):(\d+)?([\/\w \.-]*)*\/?$'

  $postgres_jdbc_syncope_url = "jdbc:postgresql://${postgres_node}:${postgres_port}/${postgres_db_name}"
  validate_re($postgres_jdbc_syncope_url, $url_re, "postgres  url is not valid url. ${postgres_jdbc_syncope_url}")
  validate_bool($jmx_enabled)

  $java_opts="\"-Xmx${java_xmx_real}m\""

  Exec {
    path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin',
  }

  class { 'tomcat':
    version => 7,
    sources => false,
  }

  if $::t_subenv == 'build' {
          tomcat::instance {'syncope-srv':
          ensure    => installed,
      }
  } else {
          tomcat::instance {'syncope-srv':
          ensure    => present,
      }
  }

  ini_setting {

    'java_xmx':
      ensure  => present,
      path    => '/etc/sysconfig/tomcat-syncope-srv',
      section => '',
      setting => 'JAVA_OPTS',
      value   => $java_opts,
      key_val_separator => '=',
      require => Tomcat::Instance['syncope-srv'];
  }


  file {
    '/srv/tomcat/syncope-srv/logs/velocity.log':
      ensure  => file,
      owner   => 'tomcat',
      group   => 'tomcat',
      mode    => '0664',
      require => Tomcat::Instance['syncope-srv'];

    '/srv/tomcat/syncope-srv/velocity.log':
      ensure => link,
      target => '/srv/tomcat/syncope-srv/logs/velocity.log',
      require => File['/srv/tomcat/syncope-srv/logs/velocity.log'];

    '/srv/tomcat/syncope-srv/webapps/syncope/WEB-INF/classes/content.xml':
      source  => 'puppet:///modules/syncope/srv/tomcat/syncope-srv/webapps/syncope/WEB-INF/classes/content.xml',
      owner   => 'tomcat',
      group   => 'tomcat',
      notify  => Service['tomcat-syncope-srv'];
  }

  package {
    'syncope':
      ensure => installed,
      notify => Service['tomcat-syncope-srv'];

    'syncope-console':
      ensure => installed,
      notify => Service['tomcat-syncope-srv'];

    'syncope-sts':
      ensure => installed,
      notify => Service['tomcat-syncope-srv'];

  }

  ini_setting {
    'jpa_url':
      ensure  => present,
      path    => '/srv/tomcat/syncope-srv/webapps/syncope/WEB-INF/classes/persistence.properties',
      section => '',
      setting => 'jpa.url',
      value   => $postgres_jdbc_syncope_url,
      notify  => Service['tomcat-syncope-srv'];

    'pgpassword':
      ensure  => present,
      path    => '/srv/tomcat/syncope-srv/webapps/syncope/WEB-INF/classes/persistence.properties',
      section => '',
      setting => 'jpa.password',
      value   => $postgres_password,
      notify  => Service['tomcat-syncope-srv'];

    'admin_password':
      ensure  => present,
      path    => '/srv/tomcat/syncope-srv/webapps/syncope/WEB-INF/classes/security.properties',
      section => '',
      setting => 'adminPassword',
      value   => $admin_password,
      notify  => Service['tomcat-syncope-srv'];
  }
    if $jmx_enabled {
       ini_setting { 'jmx_fun':
           ensure   => present,
           section  => '',
           key_val_separator => '=',
           path     => '/etc/sysconfig/tomcat-syncope-srv',
           setting  => 'JAVA_OPTS',
           value    => "\"-Xmx${java_xmx_real}m -Dcom.sun.management.jmxremote.port=7199 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false\"",
           notify  => Service['tomcat-syncope-srv'];
   }
  }

  if $cluster_enable == true {
    $syncope_nodes_formatted   = regsubst($syncope_nodes, ',', ';', 'G')
    
    $syncope_nodes_serf_args   = regsubst($syncope_nodes, ',', ' -node=', 'G')
    
    if empty($syncope_nodes_serf_args) == false {
      exec {'force-serf-update':
        command  => "serf query -node=${syncope_nodes_serf_args} forcepnow && touch /var/lock/forced_syncope_pnow.lock",
        creates  => '/var/lock/forced_syncope_pnow.lock',
        provider => 'shell',
        notify   => Service['tomcat-syncope-srv'],
      } ->
      notify {"running serf query for syncope: serf query -node=${syncope_nodes_serf_args} forcepnow":}
    }
    
    exec {'postgres-jar-link':
      command  => 'ln -fs /srv/tomcat/syncope-srv/webapps/syncope/WEB-INF/lib/postgresql* /srv/tomcat/syncope-srv/lib && touch /var/lock/postgres_jar_link.lock',
      creates  => '/var/lock/postgres_jar_link.lock',
      provider => 'shell',
      notify   => Service['tomcat-syncope-srv'],
    }

    exec {'dbcp-jar-link':
      command  => 'ln -fs /usr/share/java/tomcat/commons-dbcp.jar /srv/tomcat/syncope-srv/lib && touch /var/lock/dbcp-jar-link.lock',
      creates  => '/var/lock/dbcp-jar-link.lock',
      provider => 'shell',
      notify   => Service['tomcat-syncope-srv'],
    }

    file {'/srv/tomcat/syncope-srv/conf/context.xml':
      owner   => 'tomcat',
      group   => 'adm',
      mode    => '0644',
      content => template('syncope/srv/tomcat/syncope-srv/conf/context.xml.erb'),
      notify  => Service['tomcat-syncope-srv'],
    }

    file_line {'uncomment-resource-ref-begin':
      ensure => 'present',
      path   => '/srv/tomcat/syncope-srv/webapps/syncope/WEB-INF/web.xml',
      match  => '.*<!--<resource-ref>.*',
      line   => '<resource-ref>',
      notify => Service['tomcat-syncope-srv'],
    }

    file_line {'uncomment-resource-ref-end':
      ensure => 'present',
      path   => '/srv/tomcat/syncope-srv/webapps/syncope/WEB-INF/web.xml',
      match  => '.*</resource-ref>-->.*',
      line   => '</resource-ref>',
      notify => Service['tomcat-syncope-srv'],
    }

    file_line {'replace-presistence-context':
      ensure => 'present',
      path   => '/srv/tomcat/syncope-srv/webapps/syncope/WEB-INF/classes/persistenceContextEMFactory.xml',
      match  => '.*<entry key="openjpa.RemoteCommitProvider" value=.*',
      line   => "<entry key=\"openjpa.RemoteCommitProvider\" value=\"tcp(Addresses=${syncope_nodes_formatted})\"/>",
      after  => '<entry key="openjpa.QueryCache" value="true"/>',
      notify => Service['tomcat-syncope-srv'],
    }
    
  }

}
