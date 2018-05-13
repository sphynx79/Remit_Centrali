#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class InsertDb
  extend LightService::Action
  expects :remits, :db

  executed do |ctx|
    logger.debug('Insrisco le remit a DB')
    collection = ctx.db.collection(collection: RemitCentrali::Config.database.collection)
    ctx.remits.each do |remit|
      result = collection.update_one({ msg_id: remit[:msg_id] }, remit, upsert: true)
      logger.debug(result)
    end
  end
end
