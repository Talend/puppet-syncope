class syncope::service (

  $catalina_base  = $syncope::catalina_base,
  $service_ensure = running,

) {

  tomcat::service { 'syncope':
    service_ensure => $service_ensure,
    catalina_base  => $catalina_base,
    use_init       => false,
  }

}
