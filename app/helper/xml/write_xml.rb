#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class WriteXml
  extend LightService::Action
  expects :new_xml

  executed do |ctx|
    logger.debug("Write file xml")
    file = Time.now.strftime("#{RemitCentrali::Config.path.download}Remit_%Y%m%d_%H%M%S.xml")
    File.open(file, 'w') {|f| f.write(ctx.new_xml) }
  end
end

