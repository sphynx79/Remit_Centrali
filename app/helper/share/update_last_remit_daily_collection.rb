#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class UpdateLastRemitDailyCollection
  extend LightService::Action
  expects :db, :aggragate_last_daily_documents

  executed do |ctx|
    collection_name = RemitCentrali::Config.database.collection_centrali_last_daily
    logger.debug("Update a DB della collection #{collection_name}")
    collection = ctx.db.collection(collection: collection_name)
    collection.drop() if ctx.db.client.collections.map {|col| col.name}.include? collection_name
    collection.insert_many(ctx.aggragate_last_daily_documents, write: {w: 0})
    # collection.indexes.create_one({:dataTime => 1}, {background: true, name: 'dataTime'})
  end
end

