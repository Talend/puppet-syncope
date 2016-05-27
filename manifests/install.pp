class syncope::install () {

  package {
    'syncope':
      ensure => installed;
    'syncope-console':
      ensure => installed;
    'syncope-sts':
      ensure => installed;
  } ->

  exec{'move_syncope_to_the_right_catalina_home':
    command  => 'cp -R ',
    creates  => '/var/lock/postgres_jar_link.lock',
    provider => 'shell',
    notify   => Service['tomcat-syncope-srv'],
  }




  }


}