#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class MergePipeline
  extend LightService::Action
  expects  :pipeline_last_remit, 
           :pipeline_tec_hourly,
           :pipeline_tec_daily,
           :pipeline_zona_hourly,
           :pipeline_zona_daily

  promises :pipeline

  executed do |ctx|
    logger.debug("Merge pipeline")
    pipeline = []
    pipeline << ctx.pipeline_last_remit
    pipeline << {
      "$facet": {
        tec_hourly: ctx.pipeline_tec_hourly,
        tec_daily: ctx.pipeline_tec_daily,
        zona_hourly: ctx.pipeline_zona_hourly,
        zona_daily: ctx.pipeline_zona_daily
      }
    }
    ctx.pipeline = (pipeline.flatten(1)).freeze
  end
  
end
