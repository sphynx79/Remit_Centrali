#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class SiteConnection
  extend LightService::Action
  promises :body

  executed do |ctx|
    logger.debug('Connesione al sito PIP')
    uri = URI.parse(RemitCentrali::Config.url_rss)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.get(uri.request_uri)
    status_code = response.code
    ctx.fail_and_return!('Errore nella connesione al sito') if status_code != '200'
    ctx.body = response.body
  end
end
