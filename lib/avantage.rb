
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

      define_method(k) { |opts={}|
        get(key, required_parameters, opts) }
      define_method("#{k}_csv") { |opts={}|
        get(key, required_parameters, opts.merge!(dataType: 'csv')) } if csv

      if aliaz
        alias_method(aliaz, k)
        alias_method("#{aliaz}_csv", "#{k}_csv") if csv
      end
    end

    {
      TIME_SERIES_INTRADAY: [ nil, %w[ symbol interval ] ],
      TIME_SERIES_DAILY: [ nil, %w[ symbol ] ],
      TIME_SERIES_DAILY_ADJUSTED: [ nil, %w[ symbol ] ],
      TIME_SERIES_WEEKLY: [ nil, %w[ symbol ] ],
      TIME_SERIES_WEEKLY_ADJUSTED: [ nil, %w[ symbol ] ],
      TIME_SERIES_MONTHLY: [ nil, %w[ symbol ] ],
      TIME_SERIES_MONTHLY_ADJUSTED: [ nil, %w[ symbol ] ],
      GLOBAL_QUOTE: [ :quote, %w[ symbol ] ],
      SYMBOL_SEARCH: [ :search, %w[ keywords ] ],
    }.each { |k, v| add_endpoint(k, *v) }

    {
      CURRENCY_EXCHANGE_RATE: [ :fx, %w[ from_currency to_currency ] ],
      FX_INTRADAY: [ nil, %w[ from_symbol to_symbol interval ] ],
      FX_DAILY: [ nil, %w[ from_symbol to_symbol ] ],
      FX_WEEKLY: [ nil, %w[ from_symbol to_symbol ] ],
      FX_MONTHLY: [ nil, %w[ from_symbol to_symbol ] ],
    }.each { |k, v| add_endpoint(k, *v) }

    {
      #CURRENCY_EXCHANGE_RATE: [ nil, %w[ from_currency to_currency ] ],
      DIGITAL_CURRENCY_DAILY: [ nil, %w[ symbol market ] ],
      DIGITAL_CURRENCY_WEEKLY: [ nil, %w[ symbol market ] ],
      DIGITAL_CURRENCY_MONTHLY: [ nil, %w[ symbol market ] ],
    }.each { |k, v| add_endpoint(k, *v) }

    {
      # TODO Technical Indicators
    }.each { |k, v| add_endpoint(k, *v) }

    {
      SECTOR: [ :sectors, %w[] ],
    }.each { |k, v| add_endpoint(k, *v) }

    protected

    def get(key, required_parameters, opts)

#p [ key, required_parameters, opts ]
#TODO check required parameters

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

    def monow; Process.clock_gettime(Process::CLOCK_MONOTONIC); end
  end
end

