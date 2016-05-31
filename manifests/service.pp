class syncope::service (

  $catalina_base = $syncope::catalina_base

) {

  tomcat::service { 'syncope':
    catalina_base => $catalina_base,
    use_init      => false,
  }
}