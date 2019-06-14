
#
# Specifying avantage
#
# Fri Jun 14 17:56:24 JST 2019
#

require 'spec_helper'


describe Avantage::Client do

  before :each do

    @client = Avantage::Client.new(File.read('.api.key').strip)
  end

  describe '#quote' do

    it 'fails if "symbol" or :symbol is missing' do

      expect {
        @client.quote
      }.to raise_error(
        ArgumentError,
        'required parameter :symbol is missing from {}')
    end

    it 'returns a quote for the given symbol' do

      r = @client.quote(symbol: 'AAPL')

      expect(r['Global Quote']['01. symbol']).to eq('AAPL')
    end
  end

  describe '#symbol_search' do

    it 'returns symbol search results' do

      r = @client.symbol_search(keywords: 'xiaomi')

      expect(r.class).to eq(Hash)
      expect(r['bestMatches'].class).to eq(Array)
      expect(r['bestMatches'].size).to be > 1
      expect(r['bestMatches'][0]['2. name']).to eq('Xiaomi Corporation')
      expect(r['bestMatches'][0]['3. type']).to eq('Equity')
    end
  end

  describe '#search' do

    it 'returns symbol search results' do

      #r = @client.search(keywords: 'xiaomi')
      r = @client.search('xiaomi')

      expect(r.class).to eq(Hash)
      expect(r['bestMatches'].class).to eq(Array)
      expect(r['bestMatches'].size).to be > 1
      expect(r['bestMatches'][0]['2. name']).to eq('Xiaomi Corporation')
      expect(r['bestMatches'][0]['3. type']).to eq('Equity')
    end
  end

  describe '#sectors' do

    it 'returns sector performances' do

      r = @client.sectors

      expect(r.class).to eq(Hash)

      expect(
        r.keys
      ).to eq([
        'Meta Data',
        'Rank A: Real-Time Performance',
        'Rank B: 1 Day Performance',
        'Rank C: 5 Day Performance',
        'Rank D: 1 Month Performance',
        'Rank E: 3 Month Performance',
        'Rank F: Year-to-Date (YTD) Performance',
        'Rank G: 1 Year Performance',
        'Rank H: 3 Year Performance',
        'Rank I: 5 Year Performance',
        'Rank J: 10 Year Performance'
      ])
    end
  end
end

