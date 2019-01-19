#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class AggregatePipelineZonaDaily
  extend LightService::Action
  expects  :db, :pipeline_zona_daily
  promises :aggragate_documents_zona_daily

  executed do |ctx|
    logger.debug("Start aggregation for pipeline zona daily")
    collection_centrali_last = ctx.db.collection(collection: RemitCentrali::Config.database.collection_centrali_last)
    ctx.aggragate_documents_zona_daily = (collection_centrali_last.aggregate(ctx.pipeline_zona_daily).allow_disk_use(true).to_a).freeze
  end
end
