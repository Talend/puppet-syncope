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
  $postgres_jdbc_syncope_url = "jdbc:postgresql://${postgres_node}:${postgres_port}/${postgres_db_name}"

  $tomcat_install_from_source = true
  $tomcat_manage_user         = true
  $tomcat_manage_group        = true
  $tomcat_user                = 'tomcat'
  $tomcat_group               = 'tomcat'

  $admin_password = 'password'
  $cluster_enable = false
  $url_re = '^(jdbc:postgresql?:\/\/)?([\da-z\.-]+):(\d+)?([\/\w \.-]*)*\/?$'

}
