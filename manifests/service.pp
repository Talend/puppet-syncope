class syncope::service (

  $catalina_base = $synope::catalina_base

) {

  tomcat::service { 'tomcat':
    catalina_base => $catalina_base,
    use_init      => false,
  }
}