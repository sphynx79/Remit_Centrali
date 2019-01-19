#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class AggregatePipelineTecDaily
  extend LightService::Action
  expects  :db, :pipeline_tec_daily
  promises :aggragate_documents_tec_daily

  executed do |ctx|
    logger.debug("Start aggregation for pipeline tecnologia daily")
    collection_centrali_last = ctx.db.collection(collection: RemitCentrali::Config.database.collection_centrali_last)
    ctx.aggragate_documents_tec_daily = (collection_centrali_last.aggregate(ctx.pipeline_tec_daily).allow_disk_use(true).to_a).freeze
  end
end
