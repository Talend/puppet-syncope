class syncope::install () {

  package {
    'syncope':
      ensure => installed;
    'syncope-console':
      ensure => installed;
    'syncope-sts':
      ensure => installed;
  }

}
