require 'spec_helper'
describe 'syncope' do

let('facts') {{:memorysize_mb => 1024}}

  context 'with default values for all parameters' do
    it { should contain_class('syncope') }
  end
end
