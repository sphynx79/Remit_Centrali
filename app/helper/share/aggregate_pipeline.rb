#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class AggregatePipeline
  extend LightService::Action
  expects  :collection, :pipeline
  promises :aggragate_documents

  executed do |ctx|
    logger.debug("Start aggregation for pipeline")
    ctx.aggragate_documents = (ctx.collection.aggregate(ctx.pipeline).allow_disk_use(true).to_a).freeze
  end
end
