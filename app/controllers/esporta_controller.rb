#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class EsportaController < RemitCentrali::BaseController
  include CsvHelper

  def call
    start_date = @env[:command_options][:start_date]
    end_date   = @env[:command_options][:end_date]
    type       = @env[:command_options][:type]
    EsportaHelper.call(start_date, end_date, type)
  end
end
