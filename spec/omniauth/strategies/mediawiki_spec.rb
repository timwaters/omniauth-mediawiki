require 'spec_helper'

describe OmniAuth::Strategies::Mediawiki do
  subject do
    OmniAuth::Strategies::Mediawiki.new({})
  end

  context 'client options' do
    it 'should have correct name' do
      expect(subject.options.name).to eq('mediawiki')
    end

    it 'should have correct site' do
      expect(subject.options.client_options.site).to eq('https://commons.mediawiki.org')
    end

    it 'should have correct authorize url' do
      expect(subject.options.client_options.authorize_path).to eq('/wiki/Special:OAuth/token')
    end

    it 'should have correct access token url' do
      expect(subject.options.client_options.access_token_path).to eq('/wiki/Special:OAuth/token')
    end

    it 'should have correct request token url' do
      expect(subject.options.client_options.request_token_path).to eq('/wiki/Special:OAuth/initiate')
    end
  end
end
