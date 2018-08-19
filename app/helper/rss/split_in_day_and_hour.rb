#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

HOUR_STEP = (1.to_f / 24)

class DateTime
  def arrotonda(sec = 1)
    datetime = self.to_time
    down = datetime - (datetime.to_i % sec)
    up = down + sec

    difference_down = datetime - down
    difference_up = up - datetime

    if difference_down < difference_up
      return down.to_datetime
    else
      return up.to_datetime
    end
  end
end

class SplitInDayAndHour
  extend LightService::Action
  expects :remit

  executed do |ctx|
    logger.debug('Creo il doc per la remit da inserire a DB')
    days = []
    remit = ctx.remit
    start_date = remit[:dt_start].arrotonda(3600)
    end_date = remit[:dt_end].arrotonda(3600)
    day = remit[:dt_start].to_date
    hours = []

    start_date.step(end_date, HOUR_STEP).each do |data|
      if day == data.to_date #=> sono nello stesso giorno, uso to_date perchè altrimenti mi vedeva anche le ore
        if end_date == data #=> sono arrivato alla fine inserisco il doc e esco
          unless hours.empty?
            days << make_day(day, hours)
          end
          break
        end
        hour = data.hour + 1
        hours << make_hour(remit, data)
      else #=> sono nel giorno dopo
        unless days << make_day(day, hours)
        end
        day += 1
        hour = data.hour + 1
        hours = [make_hour(remit, data)]
      end   #=>End check stesso giorno
    end   #=>End cycle date
    remit[:days] = days
  end

  def self.make_hour(remit, data)
    last = remit[:event_status] != 'Dismissed' ?  1 : 0
    {data_hour: data , remit: remit[:unaviable_capacity].round(2), last: last.to_i}
  end

  def self.make_day(day, hours)
    # energia = hours.values.map { |h| h[:remit] }.sum
    # potenza = (energia / 24).round(1)
    # {data_day: day, data_string: day.strftime('%Y%m%d'), energia_mw: energia, potenza_mwh: potenza, hours: hours}
    {data_day: day, data_string: day.strftime('%Y%m%d'), hours: hours}
  end

  private_class_method :make_hour, :make_day
end

