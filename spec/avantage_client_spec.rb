
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
  end

  describe '#search' do
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

