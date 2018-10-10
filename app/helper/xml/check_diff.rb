#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class CheckDiff
  extend LightService::Action
  expects :last_remits, :new_remits
  promises :remits, :has_new_remit

  executed do |ctx|
    logger.debug("Controllo differenza tra il nuovo xml e l'ultimo scaricato")
    ctx.remits = (ctx.new_remits - ctx.last_remits).sort_by { |h| h[:id] }
    ctx.remits.freeze
  end
end

