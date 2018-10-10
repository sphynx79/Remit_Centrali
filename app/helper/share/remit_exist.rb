#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class RemitExist
  extend LightService::Action
  promises :remit_exist

  executed do |ctx|
    # logger.debug("Controllo se la remit con msg_id #{ctx.remit[:msg_id]} e #{ctx.remit[:event_status]} exist")
    ctx.remit_exist = ctx.collection.find( {msg_id:  ctx.remit[:msg_id], event_status: ctx.remit[:event_status]}).limit(1).count != 0 ? true : false
    logger.debug("Remit con msg_id #{ctx.remit[:msg_id]} e #{ctx.remit[:event_status]} gia presente a db") if ctx.remit_exist
  end
end
