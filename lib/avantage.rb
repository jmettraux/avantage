
require 'json'
require 'net/http'


module Avantage

  VERSION = '0.1.0'

  USER_AGENT = "avantage #{VERSION} - https://github.com/jmettraux/avantage"
  API_ROOT_URI = 'https://www.alphavantage.co/query?'

  class Client

    def initialize(api_key)

      @api_key = api_key
    end

    def self.add_endpoint(key, aliaz, required_parameters, csv=true)

      k = key.downcase

      define_method(k) { |a=nil, opts={}|
        get(key, required_parameters, a, opts) }
      define_method("#{k}_csv") { |a=nil, opts={}|
        get(key, required_parameters, a, opts.merge!(dataType: 'csv')) } if csv

      if aliaz
        alias_method(aliaz, k)
        alias_method("#{aliaz}_csv", "#{k}_csv") if csv
      end
    end

    {
      # STOCK TIME SERIES

      TIME_SERIES_INTRADAY: [ nil, %w[ symbol interval ] ],
      TIME_SERIES_DAILY: [ nil, %w[ symbol ] ],
      TIME_SERIES_DAILY_ADJUSTED: [ nil, %w[ symbol ] ],
      TIME_SERIES_WEEKLY: [ nil, %w[ symbol ] ],
      TIME_SERIES_WEEKLY_ADJUSTED: [ nil, %w[ symbol ] ],
      TIME_SERIES_MONTHLY: [ nil, %w[ symbol ] ],
      TIME_SERIES_MONTHLY_ADJUSTED: [ nil, %w[ symbol ] ],
      GLOBAL_QUOTE: [ :quote, %w[ symbol ] ],
      SYMBOL_SEARCH: [ :search, %w[ keywords ] ],

      # FOREX

      CURRENCY_EXCHANGE_RATE: [ :fx, %w[ from_currency to_currency ] ],
      FX_INTRADAY: [ nil, %w[ from_symbol to_symbol interval ] ],
      FX_DAILY: [ nil, %w[ from_symbol to_symbol ] ],
      FX_WEEKLY: [ nil, %w[ from_symbol to_symbol ] ],
      FX_MONTHLY: [ nil, %w[ from_symbol to_symbol ] ],

      # CRYPTOCURRENCIES

      #CURRENCY_EXCHANGE_RATE: [ nil, %w[ from_currency to_currency ] ],
      DIGITAL_CURRENCY_DAILY: [ nil, %w[ symbol market ] ],
      DIGITAL_CURRENCY_WEEKLY: [ nil, %w[ symbol market ] ],
      DIGITAL_CURRENCY_MONTHLY: [ nil, %w[ symbol market ] ],

      # TECHNICAL INDICATORS

      SMA: [ nil, %w[ symbol interval time_period series_type ] ],
      EMA: [ nil, %w[ symbol interval time_period series_type ] ],
      WMA: [ nil, %w[ symbol interval time_period series_type ] ],
      DEMA: [ nil, %w[ symbol interval time_period series_type ] ],
      TEMA: [ nil, %w[ symbol interval time_period series_type ] ],
      TRIMA: [ nil, %w[ symbol interval time_period series_type ] ],
      KAMA: [ nil, %w[ symbol interval time_period series_type ] ],
      MAMA: [ nil, %w[ symbol interval time_period series_type ] ],
      VWAP: [ nil, %w[ symbol interval ] ],
      T3: [ nil, %w[ symbol interval time_period series_type ] ],
      MACD: [ nil, %w[ symbol interval series_type ] ],
      MACDEXT: [ nil, %w[ symbol interval series_type ] ],
      STOCH: [ nil, %w[ symbol interval ] ],
      STOCHF: [ nil, %w[ symbol interval ] ],
      RSI: [ nil, %w[ symbol interval time_period series_type ] ],
      STOCHRSI: [ nil, %w[ symbol interval time_period series_type ] ],
      WILLR: [ nil, %w[ symbol interval time_period ] ],
      ADX: [ nil, %w[ symbol interval time_period ] ],
      ADXR: [ nil, %w[ symbol interval time_period ] ],
      PPO: [ nil, %w[ symbol interval series_type ] ],
      MOM: [ nil, %w[ symbol interval time_period series_type ] ],
      BOP: [ nil, %w[ symbol interval ] ],
      CCI: [ nil, %w[ symbol interval time_period ] ],
      # ... TODO

      # SECTOR PERFORMANCES

      SECTOR: [ :sectors, %w[] ],

    }.each { |k, v| add_endpoint(k, *v) }

    protected

    def get(key, required_parameters, a, opts)

      opts = prepare_options(key, required_parameters, a, opts)

      os = opts.merge(function: key, apikey: @api_key)

      uri = API_ROOT_URI + URI.encode_www_form(os)

      req = Net::HTTP::Get.new(uri)
      req.instance_eval { @header.clear }
      def req.set_header(k, v); @header[k] = [ v ]; end

      req.set_header('User-Agent', USER_AGENT)

      u = URI(uri)

      t0 = monow

      t = Net::HTTP.new(u.host, u.port)
      t.use_ssl = (u.scheme == 'https')
#t.set_debug_output($stdout)

      res = t.request(req)

      r = res.body
      if res.content_type.match(/\Aapplication\/json\b/)
        r = JSON.parse(r)
      end

      class << r; attr_accessor :_response, :_client, :_elapsed; end
        #
      r._response = res
      r._client = self
      r._elapsed = monow - t0

      r
    end

    VS_INTERVALS = %w[ 1min 5min 15min 30min 60min daily weekly monthly ]

    def prepare_options(key, required_parameters, a, opts)

      if a.is_a?(Hash)
        opts = a
      elsif required_parameters.any? && a != nil
        opts.merge!(required_parameters.first => a)
      end

      required_parameters.each do |rp|

        rpsy = rp.to_sym

        fail ArgumentError.new(
          "required parameter #{rpsy.inspect} is missing from #{opts.inspect}"
        ) unless opts.has_key?(rp) || opts.has_key?(rpsy)
      end

      opts
    end

    def monow; Process.clock_gettime(Process::CLOCK_MONOTONIC); end
  end
end

