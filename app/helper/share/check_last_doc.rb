#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class CheckLastDoc
  extend LightService::Action
  expects :doc_change, :collection

  executed do |ctx|
    next if ctx.doc_change.empty?
    logger.debug('Controlla se devo settare attributo last a 0 nella root del doc')
    bulk_up = []
    # ap "########################################DOC_CHANGE###############################"
    # ap ctx.doc_change

    ctx.doc_change.each do |id|
      if ctx.collection.find(_id: id).limit(1).first['days'].sum { |h| h['is_last'] } == 0
        bulk_up << {update_one: {filter: {_id: id},
                                 update: {'$set': {"is_last": 0}},
                                 bypass_document_validation: true}}
      end
    end
    ctx.collection.bulk_write(bulk_up, write: {w: 0})
  end
end

