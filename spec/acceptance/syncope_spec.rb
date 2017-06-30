require 'spec_helper'

describe 'syncope' do

  describe port(8080) do
    it { should be_listening }
  end

  describe command('/usr/bin/curl -v -f -X GET -u admin:testpassword http://localhost:8080/syncope/rest/roles 2>&1') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should include '<name>AUTHENTICATED</name>' }
      its(:stdout) { should include '<name>ACCOUNT_ADMIN</name>' }
  end

  describe file('/opt/tomcat/webapps/sts/WEB-INF/beans.xml') do
    its(:content) { should include '<property name="password" value="testpassword"/>' }
  end

  describe file('/opt/tomcat/webapps/sts/WEB-INF/classes/user.properties') do
    its(:content) { should include 'admin=testpassword' }
  end

  describe file('/opt/tomcat/webapps/activemq-security-service/WEB-INF/classes/datasource.properties') do
    its(:content) { should include 'datasource.servername=ams_db_host' }
    its(:content) { should include 'datasource.databasename=ams_db_name' }
    its(:content) { should include 'datasource.username=ams_db_user' }
    its(:content) { should include 'datasource.password=ams_db_pass' }
  end

  describe file('/opt/apache-tomcat/syncope/webapps/activemq-security-service/WEB-INF/classes/org.talend.ipaas.rt.crypto.client.cfg') do
    its(:content) { should include 'crypto.service.url=ipaas_crypto_url' }
    its(:content) { should include 'crypto.service.username=crypto_user' }
    its(:content) { should include 'crypto.service.password=crypto_pass' }
  end

  describe file('/opt/activemq-security-migration-v18to182/migration.properties') do
    its(:content) { should include 'postgresAddress=jdbc:postgresql://ams_db_host:5432/ams_db_name' }
    its(:content) { should include 'postgresUsername=ams_db_user' }
    its(:content) { should include 'postgresPassword=ams_db_pass' }
    its(:content) { should include 'crypto.service.url=ipaas_crypto_url' }
    its(:content) { should include 'crypto.service.username=crypto_user' }
    its(:content) { should include 'crypto.service.password=crypto_pass' }
  end

  describe file('/opt/activemq-security-migration-v18to20/migration.properties') do
    its(:content) { should include 'postgresAddress=jdbc:postgresql://ams_db_host:5432/ams_db_name' }
    its(:content) { should include 'postgresUsername=ams_db_user' }
    its(:content) { should include 'postgresPassword=ams_db_pass' }
    its(:content) { should include 'crypto.tpsvc.service.url=tpsvc_crypto_url' }
  end

  describe command('/usr/bin/curl -I http://localhost:8080/activemq-security-service/authenticate') do
    its(:stdout) { should include 'HTTP/1.1 401' }
  end

  describe package('activemq-security-migration-v18to182') do
    it { should be_installed }
  end

  describe package('activemq-security-migration-v18to20') do
    it { should be_installed }
  end

  describe package('activemq-security-service-v18to20') do
    it { should be_installed }
  end

  describe package('activemq-security-service-v18to182') do
    it { should be_installed }
  end

end
