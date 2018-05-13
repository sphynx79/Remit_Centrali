#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

require 'active_support/core_ext/numeric/time'

HOUR_STEP = (1.to_f / 24)

class Time
  def arrotonda(sec = 1)
    down = self - (to_i % sec)
    up = down + sec

    difference_down = self - down
    difference_up = up - self

    if difference_down < difference_up
      return down
    else
      return up
    end
  end
end

class SplitRemits
  extend LightService::Action
  expects :remits_fields
  promises :remits_hourly

  executed do |ctx|
    logger.debug('Splitto la remit in modo da avere per ogni riga una ora di remit')
    ctx.remits_hourly = ctx.remits_fields.map do |remit|
      split_hourly(remit, ctx.start_date, ctx.end_date)
    end
    ctx.remits_hourly.flatten!
    ctx.remits_hourly.freeze
  end

  #
  # Prende una riga di remit e scorre da start_date a end_date
  # e splitta in giorni e ore
  #
  # @param row_hash [Hash]
  # @param start_dt [String]
  # @param end_dt   [String]
  #
  # @return [Array<Hash>]
  #
  def self.split_hourly(row_hash, start_dt, end_dt)
    start_dt_param = Time.parse(start_dt).utc + 2.hour
    end_dt_param = Time.parse(end_dt).utc + 2.hour + 24.hour
    start_date_tmp = row_hash[:dt_start].arrotonda(60.minutes)
    end_date_tmp = row_hash[:dt_end].arrotonda(60.minutes)
    start_date = start_date_tmp <= start_dt_param ? start_dt_param : start_date_tmp
    end_date = end_date_tmp <= end_dt_param ? end_date_tmp : end_dt_param

    data = start_date
    hourly = []
    while data < end_date
      row_hash_hour = row_hash.dup
      row_hash_hour[:hour] = data.hour + 1
      row_hash_hour[:dt_flusso] = data.to_date
      row_hash_hour[:d_bdofrdt] = data.strftime('%Y%m%d')
      hourly << row_hash_hour
      data += 3600
    end
    hourly
  end
end
