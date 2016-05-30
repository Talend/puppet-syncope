class syncope::params {

  $java_home = '/usr/java/default'
  $java_xmx = undef
  $java_xmx_default = floor($::memorysize_mb * 0.70)
  $java_xmx_real = pick($java_xmx, $java_xmx_default)
  $java_opts="\"-Xmx${java_xmx_real}m\""

  $postgres_username='syncope'
  $postgres_password = undef
  $postgres_node = 'localhost'
  $postgres_port = 5432
  $postgres_db_name = 'syncope'
  $postgres_jdbc_syncope_url = "jdbc:postgresql://${postgres_node}:${postgres_port}/${postgres_db_name}"

  $admin_password = 'undef'

  $cluster_enable = false
  $syncope_nodes = undef
  $jmx_enabled = false
  $url_re = '^(jdbc:postgresql?:\/\/)?([\da-z\.-]+):(\d+)?([\/\w \.-]*)*\/?$'
  $application_path = '/opt/tomcat/webapps'


}
