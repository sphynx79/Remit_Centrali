#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

require 'rcsv'
require 'csv'

class ReadCsv
  extend LightService::Action
  promises :remits

  executed do |ctx|
    logger.debug('Leggo il file csv')
    file = "#{APP_ROOT}/#{RemitCentrali::Config.path.file_csv}"
    ctx.fail_and_return!("Non ho trovato il file #{file}") unless File.exist?(file)
    csv_data = File.open(file)
    column = { 'AcerId'               =>  { alias: :msg_id },
               'EventStatus'          =>  { alias: :event_status },
               'MarketParticipant'    =>  { alias: :market_participant },
               'TypeOfUnavailability' =>  { alias: :unavailability_type },
               'AffectedAssetMask'    =>  { alias: :etso },
               'BiddingZoneMask'      =>  { alias: :zona },
               'FuelType'             =>  { alias: :fuel_type },
               'InstalledCapacity'    =>  { alias: :install_capacity, type: :float },
               'AvailableCapacity'    =>  { alias: :available_capacity, type: :float },
               'UnavailableCapacity'  =>  { alias: :unaviable_capacity, type: :float },
               'Reason'               =>  { alias: :unavailability_reason, default: '' },
               'Published'            =>  { alias: :dt_upd, type: :date },
               'EventStart'           =>  { alias: :dt_start, type: :date },
               'EventStop'            =>  { alias: :dt_end, type: :date } }
    ctx.remits = Rcsv.parse(csv_data, column_separator: ';', header: :use, row_as_hash: true, columns: column, only_listed_columns: true)
    ctx.remits.freeze
  end
end
