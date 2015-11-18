require 'spec_helper'

describe OmniAuth::Strategies::Mediawiki do
  context 'default client options' do
    subject do
      OmniAuth::Strategies::Mediawiki.new('mediawiki', client_options: {})
    end

    it 'should have correct name' do
      expect(subject.options.name).to eq('mediawiki')
    end

    it 'should have correct site' do
      expect(subject.options.client_options.site).to eq('https://www.mediawiki.org')
    end

    it 'should have correct authorize url' do
      expect(subject.options.client_options.authorize_path).to eq('/w/index.php')
      expect(subject.options.client_options.authorize_path_title).to eq('Special:OAuth/authorize')
    end

    it 'should have correct access token url' do
      expect(subject.options.client_options.access_token_path).to eq('/w/index.php?title=Special:OAuth/token')
    end

    it 'should have correct request token url' do
      expect(subject.options.client_options.request_token_path).to eq('/w/index.php?title=Special:OAuth/initiate')
    end
  end

  context 'signup client true' do
    subject do
      OmniAuth::Strategies::Mediawiki
        .new('mediawiki', client_options: { signup: true })
        .send(:authorize_url_parameters)
    end

    it 'should set up url params to go to signup and redirect to authorize url' do
      expect(subject[:title]).to eq 'Special:UserLogin'
      expect(subject[:type]).to eq 'signup'
      expect(subject[:returnto]).to eq 'Special:OAuth/authorize'
      expect(subject[:returntoquery]).to match /oauth_consumer_key=.*/
    end
  end

  context 'authorize_path_title set manually' do
    subject do
      OmniAuth::Strategies::Mediawiki
        .new('mediawiki', client_options: { authorize_path_title: 'Special:UserLogin' })
        .send(:authorize_url_parameters)
    end

    it 'should set up url params to requested title and redirect to authorize url' do
      expect(subject[:title]).to eq 'Special:UserLogin'
      expect(subject[:type]).to be_nil
      expect(subject[:returnto]).to eq 'Special:OAuth/authorize'
      expect(subject[:returntoquery]).to match /oauth_consumer_key=.*/
    end
  end
end
