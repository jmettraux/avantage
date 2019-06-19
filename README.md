
# avantage

[![Gem Version](https://badge.fury.io/rb/avantage.svg)](http://badge.fury.io/rb/avantage)

A Ruby library to query the [Alpha Vantage API](https://www.alphavantage.co/documentation/).


## usage

The first step is to instantiate a client:
```ruby
require 'avantage'

client = Avantage::Client.new('6SAMPLEWO0KLUG55')
  # or more something like
client = Avantage::Client.new(File.read('.api.key').strip)
```

Functions may be called directly:
```ruby
require 'pp'

pp client.get(:global_quote, symbol: 'GOOG')
  #
  # ==>
  #
  # {"Global Quote"=>
  #   {"01. symbol"=>"GOOG",
  #    "02. open"=>"1109.6900",
  #    "03. high"=>"1116.3900",
  #    "04. low"=>"1098.9995",
  #    "05. price"=>"1103.6000",
  #    "06. volume"=>"1386684",
  #    "07. latest trading day"=>"2019-06-18",
  #    "08. previous close"=>"1092.5000",
  #    "09. change"=>"11.1000",
  #    "10. change percent"=>"1.0160%"}}
```

GLOBAL_QUOTE, SYMBOL_SEARCH, CURRENCY_EXCHANGE_RATE, and SECTOR can be called directly:
```ruby
client.global_quote('GOOG')
client.global_quote(symbol: 'GOOG')
client.global_quote(symbol: 'GOOG', datatype: 'csv')
client.quote('GOOG')
# ...

client.symbol_search(keywords: 'IBM')
client.symbol_search('IBM')
client.search(keywords: 'IBM')
client.search('IBM')
client.search(keywords: 'IBM', datatype: 'csv')
# ...

client.currency_exchange_rate('USD', 'JPY')
client.exchange_rate('USD', 'JPY')
client.exchange_rate(from: 'USD', to: 'JPY')
client.exchange_rate(from_currency: 'USD', to_currency: 'JPY')
client.forex(from: 'USD', to: 'JPY')
client.forex('USD', 'JPY')
client.forex(from: 'USD', to: 'JPY', datatype: 'csv')
# ...

client.sectors
client.sector
client.sectors(datatype: 'csv')
# ...
```


## license

MIT, see [LICENSE.txt](LICENSE.txt)

