require 'spec_helper'
describe 'syncope' do

  context 'with default values for all parameters' do
    it { should contain_class('syncope') }
  end
end
