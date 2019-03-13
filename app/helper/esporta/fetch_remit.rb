#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class FetchRemit
  extend LightService::Action
  expects :db, :start_date, :end_date, :type
  promises :remits

  executed do |ctx|
    logger.debug('Cerco le remit presenti nel mio db per le date scelta')
    start_dt = Date.parse(ctx.start_date)
    end_dt = Date.parse(ctx.end_date)
    collection = ctx.db.collection(collection: RemitCentrali::Config.database.collection)
    pipeline = []
    pipeline << { :$match => { "event_status": ctx.type[0].capitalize } } unless ctx.type[0] == 'all'
    pipeline << { :$match => { :$or => [{ :$and => [{ "dt_start": { :$gte => start_dt } }, { "dt_start": { :$lte => end_dt } }] }, { "dt_start": { :$lte => start_dt }, "dt_end": { :$gte => start_dt } }] } }
    pipeline << { "$project": {
      "_id": 0,
      "msg_id": '$msg_id',
      "etso": '$etso',
      "dt_upd": '$dt_upd',
      "dt_start": '$dt_start',
      "dt_end": '$dt_end',
      "fuel_type": '$fuel_type',
      "event_status": '$event_status',
      "unavailability_type": '$unavailability_type',
      "unavailability_reason": '$unavailability_reason',
      "install_capacity": '$install_capacity',
      "unaviable_capacity": '$unaviable_capacity',
      "available_capacity": '$available_capacity'
    } }
    ctx.remits = collection.aggregate(pipeline).allow_disk_use(true).to_a
    ctx.remits.freeze
  end
end
