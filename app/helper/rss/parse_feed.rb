#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

require 'rss'

class ParseFeed
  extend LightService::Action
  expects :body
  promises :remits

  executed do |ctx|
    logger.debug('Parse fedd Rss')
    # feed = File.open('feed.xml', 'r').read
    # rss = RSS::Parser.parse(feed, false)
    rss = RSS::Parser.parse(ctx.body, false)
    remits = []
    rss.items.each do |item|
      xml = item.description
      doc = Ox.parse(xml)
      node = doc.nodes[0].locate('ns1:UMM')[0]

      msg_id = node.locate('ns1:messageId')[0].text.gsub(/^0*/, '')
      event_status = node.locate('ns1:event/ns1:eventStatus')[0].text
      market_participant = node.locate('ns1:marketParticipant/ns2:name')[0].text
      unavailability_type = node.locate('ns1:unavailabilityType')[0].text
      etso = node.locate('ns1:affectedAsset/ns2:name')[0].text
      zona = node.locate('ns1:biddingZone')[0].text
      fuel_type = node.locate('ns1:fuelType')[0].text
      install_capacity = node.locate('ns1:capacity/ns1:installedCapacity')[0].text.to_f
      available_capacity = node.locate('ns1:capacity/ns1:availableCapacity')[0].text.to_f
      unaviable_capacity = node.locate('ns1:capacity/ns1:unavailableCapacity')[0].text.to_f
      unavailability_reason = node.locate('ns1:unavailabilityReason')[0].text
      dt_upd = Time.parse(node.locate('ns1:publicationDateTime')[0].text).localtime
      dt_start = Time.parse(node.locate('ns1:event/ns1:eventStart')[0].text).localtime
      dt_end = Time.parse(node.locate('ns1:event/ns1:eventStop')[0].text).localtime

      remits.push(
        msg_id: msg_id,
        event_status: event_status,
        market_participant: market_participant,
        unavailability_type: unavailability_type,
        etso: etso,
        zona: zona,
        fuel_type: fuel_type,
        install_capacity: install_capacity,
        available_capacity: available_capacity,
        unaviable_capacity: unaviable_capacity,
        unavailability_reason: unavailability_reason,
        dt_upd: dt_upd,
        dt_start: dt_start,
        dt_end: dt_end
      )
    end
    ctx.skip_remaining!('Non è presente nessuna remit da scaricare') if remits.empty?
    ctx.remits = remits
  end
end
