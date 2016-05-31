class syncope::install (


  $catalina_base = $syncope::catalina_base,
  $tomcat_version = '8',
  $tomcat_install_from_source = $syncope::tomcat_install_from_source,
  $tomcat_source_url          = $syncope::tomcat_source_url,
  $tomcat_manage_user         = $syncope::tomcat_manage_user,
  $tomcat_manage_group        = $syncope::tomcat_manage_group,
  $tomcat_user                = $syncope::tomcat_user,
  $tomcat_group               = $syncope::tomcat_group,

){

  $source_url = $tomcat_version ? {
    '7'     => 'http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.69/bin/apache-tomcat-7.0.69.tar.gz',
    default => 'http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.2/bin/apache-tomcat-8.5.2.tar.gz'
  }

  unless defined(File['/opt/tomcat']){
    file{ '/opt/tomcat':
      ensure => 'link',
      target => $catalina_base
    }
  }

  java::oracle { 'jdk8' :
    ensure  => 'present',
    version => '8',
    java_se => 'jre',
  } ->

  tomcat::instance { 'syncope':
    install_from_source => true,
    source_url          => $source_url,
    manage_user         => true,
    manage_group        => true,
    user                => 'tomcat',
    group               => 'tomcat',
    catalina_base       => $catalina_base,
    java_home           => '/usr/java/default',
  } ->

  package {
    'syncope':
      ensure => installed;
    'syncope-console':
      ensure => installed;
    'syncope-sts':
      ensure => installed;
  }

}