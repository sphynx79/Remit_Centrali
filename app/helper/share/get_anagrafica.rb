#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class GetAnagrafica
  extend LightService::Action
  promises :anagrafica

  executed do |ctx|
    logger.debug('Mi connetto al sito di mapbox per scaricare anagrafica')
    begin
      uri = URI.parse(RemitCentrali::Config.mapbox)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.get(uri.request_uri)
      status_code = response.code
    rescue
      ctx.fail_with_rollback!('Errore nella scariamneto anagrafica dal sito mapbox') if status_code != '200'
    end
    ctx.fail_with_rollback!('Errore nella scariamneto anagrafica dal sito mapbox') if status_code != '200'
    ctx.anagrafica = Oj.load(response.body, mode: :compat)['features'].map { |feature| feature['properties'] }
    ctx.anagrafica.freeze
  end
end

