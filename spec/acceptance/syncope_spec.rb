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

end
