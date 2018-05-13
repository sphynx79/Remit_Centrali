#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class ConnectDb
  extend LightService::Action
  promises :db

  executed do |ctx|
    logger.debug('Connessione al dababase')
    db = CentraliModel.new
    ctx.fail_with_rollback!(db.client) unless db.client.is_a?(Mongo::Client)
    ctx.db = db
  end
end
