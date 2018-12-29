#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class AggregatePipelineLast
  extend LightService::Action
  expects  :collection, :pipeline_last_remit
  promises :aggragate_last_documents

  executed do |ctx|
    logger.debug("Start aggregation for pipeline last")
    ctx.aggragate_last_documents = (ctx.collection.aggregate(ctx.pipeline_last_remit).allow_disk_use(true).to_a).freeze
  end
end
