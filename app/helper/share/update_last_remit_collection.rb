#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class UpdateLastRemitCollection
  extend LightService::Action
  expects :collection

  executed do |ctx|
    logger.debug('Eseguo update a DB della collection remit_centrali_last')
    ctx.collection.aggregate(pipeline, {bypassDocumentValidation: true}).allow_disk_use(true).count
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

    pipeline << {
      "$out": RemitCentrali::Config.database.collection_last,
    }

    pipeline
  end

  private_class_method :pipeline
end

