#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class UpdateZonaHourlyCollection
  extend LightService::Action
  expects :collection_last

  executed do |ctx|
    logger.debug('Eseguo update a DB della collection remit_centrali_hourly_zona')
    ctx.collection_last.aggregate(pipeline, {bypassDocumentValidation: true}).allow_disk_use(true).count
  end

  def self.pipeline
    pipeline = []
    pipeline << {
      "$group": {
        _id: {
          dateTime: '$data_hour',
          zona: '$zona',
        },
        totalremit: {
          "$sum": '$remit',
        },
      },
    }
    pipeline << {
      "$group": {
        "_id": '$_id.dateTime',
        "zona": {
          "$push": {
            k: '$_id.zona',
            v: '$totalremit',
          },
        },
      },
    }
    pipeline << {
      "$replaceRoot": {
        "newRoot": {
          "$mergeObjects": [{
            "$arrayToObject": '$zona',
          },
                            '$$ROOT'],
        },
      },
    }
    pipeline << {
      "$project": {
        _id: 0,
        dataTime: '$_id',
        brnn: {
          "$ifNull": ['$BRNN', 0],
        },
        cnor: {
          "$ifNull": ['$CNOR', 0],
        },
        csud: {
          "$ifNull": ['$CSUD', 0],
        },
        fogn: {
          "$ifNull": ['$FOGN', 0],
        },
        nord: {
          "$ifNull": ['$NORD', 0],
        },
        prgp: {
          "$ifNull": ['$PRGP', 0],
        },
        rosn: {
          "$ifNull": ['$ROSN', 0],
        },
        sard: {
          "$ifNull": ['$SARD', 0],
        },
        sici: {
          "$ifNull": ['$SICI', 0],
        },
        sud: {
          "$ifNull": ['$SUD', 0],
        },
      },
    }

    pipeline << {"$sort": {"dataTime": 1}}

    pipeline << {
      "$out": 'remit_centrali_hourly_zona',
    }

    pipeline
  end
end

