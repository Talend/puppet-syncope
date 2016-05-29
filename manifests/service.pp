class syncope::service (

) {

  tomcat::setenv::entry { 'JAVA_OPTS':
    value      => [
      '-Xmx1024m'
      ],
    quote_char    => '"',
    catalina_home => '/opt/tomcat',
    notify        => Service['tomcat-syncope']
  }

  tomcat::service { 'syncope':
    catalina_base => '/opt/tomcat',
    use_init      => false,
  }

}
