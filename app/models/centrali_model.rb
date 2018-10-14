#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class CentraliModel < RemitCentrali::BaseModel
  def collection(collection: 'remit_centrali')
    client[collection]
  end
    
end
