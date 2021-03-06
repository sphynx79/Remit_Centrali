#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class SetPipelineTecDaily
  extend LightService::Action
  promises :pipeline_tec_daily

  executed do |ctx|
    logger.debug('Set pipile tecnologia daily')
    ctx.pipeline_tec_daily = (pipeline).freeze
  end

  def self.pipeline
    pipeline = []

    # raggruppo e sommo le ore del giorno pensando giàal timezone italiano
    pipeline << {
      "$project": {
        _id: 0,
        year: {"$year": {date: '$data_hour', timezone: 'Europe/Rome'}},
        month: {"$month": {date: '$data_hour', timezone: 'Europe/Rome'}},
        dayOfMonth: {"$dayOfMonth": {date: '$data_hour', timezone: 'Europe/Rome'}},
        tipo: '$tipo',
        remit: '$remit',
      },
    }

    pipeline << {
      "$group": {
        _id: {
          year: '$year',
          month: '$month',
          dayOfMonth: '$dayOfMonth',
          tipo: '$tipo',
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
        tipo: {
          "$push": {
            k: '$_id.tipo',
            v: {"$divide": ['$totalremit', 24]},
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
        dataTime: {"$dateFromParts": {"year": "$_id.year", "month": "$_id.month", "day": "$_id.dayOfMonth"}},
        # data: {"$concat": [ { "$toString": "$_id.dayOfMonth" } , "-" ,  { "$toString": "$_id.month" } , "-", { "$toString": "$_id.year" }]},
        data: { 
            "$concat": [
                { "$cond": [
                    { "$lte": [ "$_id.dayOfMonth", 9 ] },
                    { "$concat": [
                        "0", { "$substr": [ { "$toString": "$_id.dayOfMonth" }, 0, 2 ] }
                    ]},
                    { "$substr": [ { "$toString": "$_id.dayOfMonth" }, 0, 2 ] }
                ]},
                "-",
                { "$cond": [
                    { "$lte": [ "$_id.month", 9 ] },
                    { "$concat": [
                        "0", { "$substr": [ { "$toString": "$_id.month" }, 0, 2 ] }
                    ]},
                    { "$substr": [ { "$toString": "$_id.month" }, 0, 2 ] }
                ]},
                "-",
                { "$toString": "$_id.year" }
            ]
        },
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

  end

  private_class_method :pipeline
end

