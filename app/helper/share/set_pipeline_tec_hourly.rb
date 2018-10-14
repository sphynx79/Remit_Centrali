#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class SetPipelineTecHourly
  extend LightService::Action
  promises :pipeline_tec_hourly

  executed do |ctx|
    logger.debug('Set pipile tecnologia hourly')
    ctx.pipeline_tec_hourly = (pipeline).freeze
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
  end

  private_class_method :pipeline
end

