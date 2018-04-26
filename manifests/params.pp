class syncope::params {

  $java_xmx = floor($::memorysize_mb * 0.70)
  $java_opts="\"-Xmx${java_xmx}m\""
  $catalina_base = '/opt/apache-tomcat/syncope'
  $application_path = "${catalina_base}/webapps"

  $postgres_username = 'syncope'
  $postgres_password = 'syncope'
  $postgres_host     = 'localhost'
  $postgres_port     = 5432
  $postgres_db_name  = 'syncope'

  $syncope_version            = '1.2.1-11'
  $syncope_console_version    = '1.2.1-9'
  $sts_version                = '1.2.1-10'

  $tomcat_install_from_source = true
  $tomcat_manage_user         = true
  $tomcat_manage_group        = true

  $admin_password = 'password'

  $ams_security_version = '2.2.0-1'
  $ams_security_db_host = 'localhost'
  $ams_security_db_name = 'ams_name'
  $ams_security_db_user = 'ams_user'
  $ams_security_db_pass = 'ams_pass'

  $tpsvc_crypto_url  = ''

}
