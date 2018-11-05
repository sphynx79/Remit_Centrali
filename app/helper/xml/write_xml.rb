#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class WriteXml
  extend LightService::Action
  expects :new_xml
  promises :new_file_xml

  executed do |ctx|
    logger.debug("Write file xml")
    ctx.new_file_xml = TZ.utc_to_local(Time.now).strftime("#{APP_ROOT}/#{RemitCentrali::Config.path.download}Remit_%Y%m%d_%H%M%S.xml")
    File.open(ctx.new_file_xml, 'w') {|f| f.write(ctx.new_xml) }
  end

  rolled_back do |ctx|
    FileUtils.rm_f(ctx.new_file_xml)
  end
end

