class syncope::params {

  $java_home = '/usr/java/default'
  $java_xmx = floor($::memorysize_mb * 0.70)
  $java_opts="\"-Xmx${java_xmx}m\""
  $catalina_base = '/opt/apache-tomcat/syncope'
  $application_path = "${catalina_base}/webapps"

  $postgres_username='syncope'
  $postgres_password = undef
  $postgres_node = 'localhost'
  $postgres_port = 5432
  $postgres_db_name = 'syncope'

  $tomcat_install_from_source = true
  $tomcat_manage_user         = true
  $tomcat_manage_group        = true
  $tomcat_user                = 'tomcat'
  $tomcat_group               = 'tomcat'

  $admin_password = sha1('password')
  $cluster_enable = false

}
