#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class CsvController < RemitCentrali::BaseController
  include CsvHelper

  def call
    CsvHelper.call(@env)
  end
end
