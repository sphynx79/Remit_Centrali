#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class RssController < RemitCentrali::BaseController
  include RssHelper

  def call
    RssHelper.call
  end
end
