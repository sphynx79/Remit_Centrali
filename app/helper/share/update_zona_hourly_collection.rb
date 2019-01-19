#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class UpdateZonaHourlyCollection
  extend LightService::Action
  expects :db, :aggragate_documents_zona_hourly

  executed do |ctx|
    collection_name = RemitCentrali::Config.database.collection_centrali_zona_hourly
    logger.debug("Update a DB della collection #{collection_name}")
    collection = ctx.db.collection(collection: collection_name)
    collection.drop() if ctx.db.client.collections.map {|col| col.name}.include? collection_name
    collection.insert_many(ctx.aggragate_documents_zona_hourly, write: {w: 0})
    collection.indexes.create_one({:data => 1}, {background: true, name: 'data'})
    collection.indexes.create_one({:dataTime => 1}, {background: true, name: 'datatime'})
  end

end

