# frozen_string_literal: true

require 'spec_helper'

describe 'graylog' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it {
        is_expected.to compile.and_raise_error(%r{use the \"graylog::server\" class})
      }
    end
  end
end
