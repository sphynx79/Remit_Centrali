#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class UpdateTecnologiaHourlyCollection
  extend LightService::Action
  expects :collection_last, :db

  executed do |ctx|
    logger.debug('Eseguo update a DB della collection remit_centrali_hourly_tecologia')
    #ctx.collection_last.aggregate(pipeline, {bypassDocumentValidation: true}).allow_disk_use(true).count
    documents = ctx.collection_last.aggregate(pipeline).allow_disk_use(true).to_a
    collection = ctx.db.collection(collection: 'remit_centrali_hourly_tecologia')
    collection.drop()
    collection.insert_many(documents, write: {w: 0})
    collection.indexes.create_one({:dataTime => 1}, {background: true, name: 'dataTime'})
  end

  def self.pipeline
    pipeline = []

    pipeline << {
      "$group": {
        _id: {
          dateTime: '$data_hour',
          tipo: '$tipo',
        },
        totalremit: {
          "$sum": '$remit',
        },
      },
    }

    pipeline << {
      "$group": {
        "_id": '$_id.dateTime',
        "tipo": {
          "$push": {
            k: '$_id.tipo',
            v: '$totalremit',
          },
        },
      },
    }

    pipeline << {
      "$replaceRoot": {
        "newRoot": {
          "$mergeObjects": [{
            "$arrayToObject": '$tipo',
          },
                            '$$ROOT'],
        },
      },
    }

    pipeline << {
      "$project": {
        _id: 0,
        dataTime: '$_id',
        termico: {
          "$ifNull": ['$TERMICO', 0],
        },
        pompaggio: {
          "$ifNull": ['$POMPAGGIO', 0],
        },
        autoproduttore: {
          "$ifNull": ['$AUTOPRODUTTORE', 0],
        },
        idrico: {
          "$ifNull": ['$IDRICO', 0],
        },
        eolico: {
          "$ifNull": ['$EOLICO', 0],
        },
        solare: {
          "$ifNull": ['$SOLARE', 0],
        },
        geotermico: {
          "$ifNull": ['$GEOTERMICO', 0],
        },
      },
    }

    pipeline << {"$sort": {"dataTime": 1}}

    # pipeline << {
    #   "$out": 'remit_centrali_hourly_tecologia',
    # }
  end

  private_class_method :pipeline
end

