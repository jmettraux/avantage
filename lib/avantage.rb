
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

    def global_quote(symbol)

      os = symbol.is_a?(Hash) ? symbol : { symbol: symbol }

      get('GLOBAL_QUOTE', os)
    end
    alias quote global_quote

    def symbol_search(keywords)

      os = keywords.is_a?(Hash) ? keywords : { keywords: keywords }

      get('SYMBOL_SEARCH', os)
    end
    alias search symbol_search

    def sector(os={})

      get('SECTOR', os)
    end
    alias sectors sector

    def currency_exchange_rate(from, to=nil)

      os =
        if from.is_a?(Hash)
          from.inject({}) { |k, v|
            if k == :from
              h[:from_currency] = v
            elsif k == :to
              h[:to_currency] = v
            else
              h[k] = v
            end
            h }
        else
          { from_currency: from, to_currency: to }
        end

      get('CURRENCY_EXCHANGE_RATE', os)
    end
    alias exchange_rate currency_exchange_rate
    alias forex currency_exchange_rate

    def get(function, parameters)

      func = function.to_s.upcase

      params = parameters.merge(function: func, apikey: @api_key)
      params[:datatype] = 'json' if params.delete(:json)
      params[:datatype] = 'csv' if params.delete(:csv)

      uri = API_ROOT_URI + URI.encode_www_form(params)

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

    protected

    def monow; Process.clock_gettime(Process::CLOCK_MONOTONIC); end
  end
end

