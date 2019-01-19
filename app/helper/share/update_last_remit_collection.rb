#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class UpdateLastRemitCollection
  extend LightService::Action
  expects :db, :aggragate_last_documents

  executed do |ctx|
    collection_name = RemitCentrali::Config.database.collection_centrali_last
    logger.debug("Update a DB della collection #{collection_name}")
    collection = ctx.db.collection(collection: collection_name)
    collection.drop() if ctx.db.client.collections.map {|col| col.name}.include? collection_name
    collection.insert_many(ctx.aggragate_last_documents, write: {w: 0})
    collection.indexes.create_one({:data => 1}, {background: true, name: 'data'})
  end
end

