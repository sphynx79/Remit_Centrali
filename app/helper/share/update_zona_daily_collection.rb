#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class UpdateZonaDailyCollection
  extend LightService::Action
  expects :collection_last

  executed do |ctx|
    logger.debug('Eseguo update a DB della collection remit_centrali_daily_zona')
    ctx.collection_last.aggregate(pipeline, {bypassDocumentValidation: true}).allow_disk_use(true).count
  end

  def self.pipeline
    pipeline = []

    pipeline << {
      "$project": {
        _id: 0,
        year: {"$year": {date: '$data_hour', timezone: 'Europe/Rome'}},
        month: {"$month": {date: '$data_hour', timezone: 'Europe/Rome'}},
        dayOfMonth: {"$dayOfMonth": {date: '$data_hour', timezone: 'Europe/Rome'}},
        data: '$data_hour',
        zona: '$zona',
        remit: '$remit',
      },
    }

    pipeline << {
      "$group": {
        _id: {
          year: '$year',
          month: '$month',
          dayOfMonth: '$dayOfMonth',
          zona: '$zona',
        },
        totalremit: {
          "$sum": '$remit',
        },
      },
    }

    pipeline << {
      "$group": {
        _id: {
          year: '$_id.year',
          month: '$_id.month',
          dayOfMonth: '$_id.dayOfMonth',
        },
        zona: {
          "$push": {
            k: '$_id.zona',
            v: {"$divide": ['$totalremit', 24]},
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
        dataTime: {"$dateFromParts": {'year': '$_id.year', 'month': '$_id.month', 'day': '$_id.dayOfMonth'}},
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
      "$out": 'remit_centrali_daily_zona',
    }
  end
end

