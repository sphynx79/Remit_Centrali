#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

require 'csv'

class ScriviCsv
  extend LightService::Action
  expects :remits_hourly

  executed do |ctx|
    csv_path = RemitCentrali::Config.path.csv_esporta
    csv = CSV.open(csv_path, 'w+')
    num_rec = 0
    ctx.remits_hourly.each_with_index do |doc, index|
      csv << doc.to_h.keys if index.zero?
      csv << doc.values
      num_rec += 1
    end
    logger.debug("Esportato #{num_rec} righe")
  end
end
