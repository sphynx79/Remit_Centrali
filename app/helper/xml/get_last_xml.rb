#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class GetLastXml
  extend LightService::Action
  promises :last_xml

  executed do |ctx|
    ctx.last_xml = nil
    logger.debug("Leggo l'ultimo xml scaricato")
    last_file = Dir.glob("#{RemitCentrali::Config.path.download}*.xml").max_by {|f|  File.stat(f).mtime}
    ctx.last_xml = File.read(last_file) if last_file
  end
end
