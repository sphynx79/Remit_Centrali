#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class CheckLastDay
  extend LightService::Action
  expects :days_change, :collection
  promises :doc_change

  executed do |ctx|
    ctx.doc_change = Set[]
    next if ctx.days_change.empty?
    logger.debug("Controlla se devo settare attributo last a 0 dei days")
    bulk_up = []
    # ap "###########################DAYS_CHANEG##########################"
    # ap ctx.days_change

    ctx.days_change.each do |doc|
      id = doc[:id]
      index_day = doc[:index_day]
      if ctx.collection.find(_id: id).limit(1).first["days"][index_day]["hours"].sum {|h| h["is_last"] } == 0
          bulk_up << { update_one: { filter: { _id: id }, 
                                     update: { '$set': { "days.#{index_day}.is_last": 0 } }, 
                                     bypass_document_validation: true 
          }}
          ctx.doc_change << id
      end
    end
    ctx.collection.bulk_write(bulk_up, write: { w: 0 })
  end 
end
