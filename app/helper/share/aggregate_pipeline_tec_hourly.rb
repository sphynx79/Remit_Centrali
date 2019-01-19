#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class AggregatePipelineTecHourly
  extend LightService::Action
  expects  :db, :pipeline_tec_hourly
  promises :aggragate_documents_tec_hourly

  executed do |ctx|
    logger.debug("Start aggregation for pipeline tecnologia hourly")
    collection_centrali_last = ctx.db.collection(collection: RemitCentrali::Config.database.collection_centrali_last)
    ctx.aggragate_documents_tec_hourly = (collection_centrali_last.aggregate(ctx.pipeline_tec_hourly).allow_disk_use(true).to_a).freeze
  end
end
