#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class CheckLastUpd
  extend LightService::Action
  expects :remits
  promises :last_read

  executed do |ctx|
    last_msg_id = ctx.remits.last[:msg_id]
    file = "#{APP_ROOT}/#{RemitCentrali::Config.path.file_dt_upd}"
    if File.exist?(file)
      last_read = File.open(file, 'r').first
    else
      last_read = ''
      File.open(file, 'w') { |f| f << last_read }
    end

    ctx.skip_remaining!('Nessuna remit da scaricare') if last_msg_id == last_read
    open(file, 'w') do |f|
      f.flock(File::LOCK_EX)
      f << last_msg_id
    end
    ctx.last_read = last_read
  end

  rolled_back do |ctx|
    file = "#{APP_ROOT}/#{Config.path.file_dt_upd}"
    open(file, 'w') do |f|
      f.flock(File::LOCK_EX)
      f << ctx.last_read
    end
  end
end
