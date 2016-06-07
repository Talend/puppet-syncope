require 'spec_helper_acceptance'

shared_examples 'syncope::running' do

  describe port(8080) do
    it { should be_listening }
  end
end
