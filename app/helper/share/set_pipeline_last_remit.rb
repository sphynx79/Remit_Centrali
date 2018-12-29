#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class SetPipelineLastRemit
  extend LightService::Action
  promises :pipeline_last_remit

  executed do |ctx|
    logger.debug('Set pipile last remit')
    ctx.pipeline_last_remit = (pipeline).freeze
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
      "$sort": {"hours.data_hour": 1},
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
        "data": {"$dateToString": {
            format: "%d-%m-%Y",
            date: '$hours.data_hour',
            timezone: 'Europe/Rome',
        }},
        "year": {"$year": {date: '$hours.data_hour', timezone: 'Europe/Rome'}},
        "month": {"$month": {date: '$hours.data_hour', timezone: 'Europe/Rome'}},
        "dayOfMonth": {"$dayOfMonth": {date: '$hours.data_hour', timezone: 'Europe/Rome'}},
      },
    }

  end

  private_class_method :pipeline
end

