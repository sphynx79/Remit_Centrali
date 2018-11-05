#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class SetPipelineLastRemitDaily
  extend LightService::Action
  promises :pipeline_last_daily

  executed do |ctx|
    logger.debug('Set pipile last remit daily')
    ctx.pipeline_last_daily = (pipeline).freeze
  end

  def self.pipeline
    pipeline = []

    pipeline << {
      "$match": {
        "is_last": 1,
      },
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
      "$group": {
        _id: {
          day: '$days.data_day',
        },
        remits: {
          "$push": {
            msg_id: '$msg_id',
            etso: '$etso',
            dt_upd: '$dt_upd',
            dt_start: '$dt_start',
            dt_end: '$dt_end',
            remit: '$unaviable_capacity',
            hours: '$days.hours',
          },
        },
      },
    }

    pipeline << {
      "$project": {
        _id: 0,
        data: '$_id.day',
        data_string: {
          "$dateToString": {
            format: '%Y-%m-%d %H:%M:%S',
            date: '$_id.day',
          # timezone: "Europe/Rome"
          },
        },
        remits: 1,
        hours: 1,
      },
    }

    pipeline << {
      "$sort": {
        data: 1,
      },
    }

    # pipeline << {
    #   "$project": {
    #     _id: 0,
    #     msg_id: 1,
    #     etso: 1,
    #     dt_upd: 1,
    #     dt_start: 1,
    #     dt_end: 1,
    #     hours: '$days.hours',
    #   },
    # }

    # pipeline << {
    #   "$unwind": '$hours',
    # }

    # pipeline << {
    #   "$match": {
    #     "hours.is_last": 1,
    #   },
    # }

    # pipeline << {
    #   "$project": {
    #     "_id": 0,
    #     "msg_id": '$msg_id',
    #     "dt_end": '$dt_end',
    #     "dt_start": '$dt_start',
    #     "dt_upd": '$dt_upd',
    #     "etso": '$etso',
    #     "tipo": '$tipo',
    #     "zona": '$zona',
    #     "remit": '$hours.remit',
    #     "data_hour": '$hours.data_hour',
    #   },
    # }

  end

  private_class_method :pipeline
end

