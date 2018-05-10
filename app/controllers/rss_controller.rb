#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class RssController < RemitCentrali::BaseController
  # include LightService::Organizer
  include RssHelper

  def call
    # db = TransmissionModel.new
    # db.collection(collection: 'remit_centrali')
    RssHelper.call
  end
end

# class Ciao
#   extend LightService::Action

#   executed do |context|
#     # puts "download_controller.rb::#{__LINE__}\n"
#     # ap context
#   end
# end
