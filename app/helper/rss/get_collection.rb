#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class GetCollection
  extend LightService::Action
  expects  :db
  promises :collection

  executed do |ctx|
    ctx.collection = ctx.db.collection(collection: RemitCentrali::Config.database.collection)
  end
end
