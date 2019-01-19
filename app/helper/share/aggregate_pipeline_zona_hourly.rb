#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class AggregatePipelineZonaHourly
  extend LightService::Action
  expects  :db, :pipeline_zona_hourly
  promises :aggragate_documents_zona_hourly

  executed do |ctx|
    logger.debug("Start aggregation for pipeline zona hourly")
    collection_centrali_last = ctx.db.collection(collection: RemitCentrali::Config.database.collection_centrali_last)
    ctx.aggragate_documents_zona_hourly = (collection_centrali_last.aggregate(ctx.pipeline_zona_hourly).allow_disk_use(true).to_a).freeze
  end
end
