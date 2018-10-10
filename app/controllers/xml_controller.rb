#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class XmlController < RemitCentrali::BaseController
  include XmlHelper

  def call
    XmlHelper.call(@env)
  end
end
