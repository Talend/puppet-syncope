class syncope::params {

  $java_home = '/usr/java/default'
  $java_xmx = undef
  $java_xmx_default = floor($::memorysize_mb * 0.70)
  $java_xmx_real = pick($java_xmx, $java_xmx_default)
  $java_opts="\"-Xmx${java_xmx_real}m\""
  $catalina_base = '/opt/apache-tomcat/syncope'
  $application_path = "${catalina_base}/webapps"

  $postgres_username='syncope'
  $postgres_password = undef
  $postgres_node = 'localhost'
  $postgres_port = 5432
  $postgres_db_name = 'syncope'
  $postgres_jdbc_syncope_url = "jdbc:postgresql://${postgres_node}:${postgres_port}/${postgres_db_name}"

  $tomcat_install_from_source = true
  $tomcat_source_url          = $source_url
  $tomcat_manage_user         = true
  $tomcat_manage_group        = true
  $tomcat_user                = 'tomcat'
  $tomcat_group               = 'tomcat'
  $tomcat_catalina_base       = $catalina_base
  $tomcat_java_home           = $java_home

  $admin_password = 'undef'
  $cluster_enable = false
  $jmx_enabled = false
  $url_re = '^(jdbc:postgresql?:\/\/)?([\da-z\.-]+):(\d+)?([\/\w \.-]*)*\/?$'



}
