#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class UpdateLastRemitCollection
  extend LightService::Action
  expects :collection, :collection_last

  executed do |ctx|
    logger.debug('Eseguo update a DB della collection remit_centrali_last')
    # documents = ctx.collection.aggregate(pipeline).allow_disk_use(true).count
    indexes = []
    documents = ctx.collection.aggregate(pipeline).allow_disk_use(false).to_a
    ctx.collection_last.drop()
    ctx.collection_last.insert_many(documents, write: { w: 0 })
    ctx.collection_last.indexes.create_one({ :data_hour => 1 }, {background: true, name: "data_hour"})
    
    # ctx.collection_last.indexes.each { |x| indexes << x["key"] if x["key"].keys[0] != "_id" }
    # indexes.each do |index|
    #   ctx.collection_last.indexes.create_one(index, {background: true, name: index.keys[0]})
    # end
  end

  def self.pipeline
    pipeline = []

    pipeline << {
      "$match": {
        "is_last": 1
      }
    }

    pipeline << {
      "$unwind": '$days',
    }

    pipeline << {
      "$match": {
        "days.is_last": 1,
      },
    }

    pipeline << {
      "$project": {
        _id: 0,
        msg_id: 1,
        etso: 1,
        zona: 1,
        tipo: 1,
        dt_upd: 1,
        dt_start: 1,
        dt_end: 1,
        hours: '$days.hours',
      },
    }

    pipeline << {
      "$unwind": '$hours',
    }

    pipeline << {
      "$match": {
        "hours.is_last": 1,
      },
    }

    pipeline << {
      "$project": {
        "_id": 0,
        "msg_id": '$msg_id',
        "dt_end": '$dt_end',
        "dt_start": '$dt_start',
        "dt_upd": '$dt_upd',
        "etso": '$etso',
        "tipo": '$tipo',
        "zona": '$zona',
        "remit": '$hours.remit',
        "data_hour": '$hours.data_hour',
      },
    }

    # pipeline << {
    #   "$out": RemitCentrali::Config.database.collection_last,
    # }
  end

  private_class_method :pipeline
end

