#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class GetCollectionLast
  extend LightService::Action
  expects  :db
  promises :collection_last

  executed do |ctx|
    ctx.collection_last = ctx.db.collection(collection: RemitCentrali::Config.database.collection_last)
  end
end
