#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class AggregatePipelineLastDaily
  extend LightService::Action
  expects  :collection, :pipeline_last_daily
  promises :aggragate_last_daily_documents

  executed do |ctx|
    logger.debug("Start aggregation for pipeline last daily")
    ctx.aggragate_last_daily_documents = (ctx.collection.aggregate(ctx.pipeline_last_daily).allow_disk_use(true).to_a).freeze
  end
end
