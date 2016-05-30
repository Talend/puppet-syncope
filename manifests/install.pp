class syncope::install () {

  package {
    'syncope':
      require => File['/opt/tomcat'],
      ensure => installed;
    'syncope-console':
      require => File['/opt/tomcat'],
      ensure => installed;
    'syncope-sts':
      require => File['/opt/tomcat'],
      ensure => installed;
  }

}