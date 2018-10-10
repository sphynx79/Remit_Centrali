#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class ParseNewXml
  extend LightService::Action
  expects :new_xml
  promises :new_remits

  executed do |ctx|
    logger.debug('Parse new xml')
    doc = Ox.parse(ctx.new_xml)
    remits = []
   doc.nodes[0].each do |node|
      hash_orig = Hash[node.nodes.collect { |x| [x.value, x.nodes[0]] }]
      hash_dest = {}
      hash_dest[:id] =  hash_orig['Id']
      hash_dest[:msg_id] =  hash_orig['AcerId']
      hash_dest[:event_status] = hash_orig['EventStatus'] != 'Dismissed' ? 'Active' : 'Dismissed'
      hash_dest[:market_participant] = hash_orig['MarketParticipant']
      hash_dest[:unavailability_type] = hash_orig['TypeOfUnavailability']
      hash_dest[:etso] = hash_orig['AffectedAsset']
      hash_dest[:zona] = hash_orig['BiddingZone']
      hash_dest[:fuel_type] = hash_orig['FuelType']
      hash_dest[:install_capacity] = hash_orig['InstalledCapacity'].to_f
      hash_dest[:available_capacity] = hash_orig['AvailableCapacity'].to_f
      hash_dest[:unaviable_capacity] = hash_orig['UnavailableCapacity'].to_f
      hash_dest[:unavailability_reason] = hash_orig['Reason']
      hash_dest[:dt_upd] = DateTime.parse(hash_orig['Published'])
      hash_dest[:dt_start] = DateTime.parse(hash_orig['EventStart'])
      hash_dest[:dt_end] = DateTime.parse(hash_orig['EventStop'])
      if hash_dest[:dt_end] > (DateTime.now + 1095)
        hash_dest[:dt_end] = Date.today.to_datetime + 1095
      end
      remits.push(hash_dest)
    end
    ctx.new_remits = remits
    ctx.new_remits.freeze
    File.open('new.yaml', 'w') {|f| f.write ctx.new_remits.to_yaml }
  end
end

