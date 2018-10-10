#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class GetNewXml
  extend LightService::Action
  promises :new_xml

  executed do |ctx|
    logger.debug('Scarico il file xml delle remit')
    response = Net::HTTP.get_response(URI.parse(RemitCentrali::Config.url_xml))
    ctx.fail_and_return!('Errore nella connesione al sito') if response.code != '200'
    ctx.new_xml = response.body
  end
end
