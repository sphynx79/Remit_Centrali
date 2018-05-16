#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class EsportaController < RemitCentrali::BaseController
  include CsvHelper

  def call
    EsportaHelper.call(@env)
  end
end
