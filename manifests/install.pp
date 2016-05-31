class syncope::install () {

  package {
    'syncope':
      require => Tomcat::Instance['tomcat'],
      ensure => installed;
    'syncope-console':
      require => Tomcat::Instance['tomcat'],
      ensure => installed;
    'syncope-sts':
      require => Tomcat::Instance['tomcat'],
      ensure => installed;
  }

}