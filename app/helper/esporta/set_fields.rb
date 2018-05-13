#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class SetFields
  extend LightService::Action
  expects :anagrafica, :remits
  promises :remits_fields

  executed do |ctx|
    logger.debug('Setto i campi da inserire nel mio csv')
    ctx.remits_fields = ctx.remits.map do |remit|
      field = {}
      etso = remit['etso']
      anagrafica_unita = ctx.anagrafica.lazy.select { |f| f['etso'] == etso }.first
      ctx.fail_and_return!("Non ho trovato l'#{etso} in anagrafica") if anagrafica_unita.nil?
      field[:msg_id] = remit['msg_id']
      field[:event_status] = remit['event_status']
      field[:unavailability_type] = remit['unavailability_type']
      field[:unavailability_reason] = remit['unavailability_reason']
      field[:etso] = etso
      field[:dt_upd] = remit['dt_upd']
      field[:dt_start] = remit['dt_start']
      field[:dt_end] = remit['dt_end']
      field[:fuel_type] = remit['fuel_type']
      field[:company] = anagrafica_unita['company']
      field[:operatore] = anagrafica_unita['operatore']
      field[:proprietario] = anagrafica_unita['proprietario']
      field[:localita_estesa] = anagrafica_unita['localita_estesa']
      field[:impianto] = anagrafica_unita['impianto']
      field[:sottotipo] = anagrafica_unita['sottotipo']
      field[:zona] = anagrafica_unita['zona']
      field[:localita] = anagrafica_unita['localita']
      field[:provincia] = anagrafica_unita['provincia']
      field[:descrizione] = anagrafica_unita['descrizione']
      field[:tipo] = anagrafica_unita['tipo']
      field[:p_min] = anagrafica_unita['pmin'].to_i
      field[:p_max] = remit['install_capacity'].to_i
      field[:v_remit] = remit['unaviable_capacity'].to_i
      field[:p_disp] = remit['available_capacity'].to_i
      field[:stato] = stato(field[:p_disp], field[:p_min])
      field[:chk_disp] = chk_disp(field[:stato], field[:p_disp], field[:p_max])
      field[:msd] = anagrafica_unita['msd']
      field
    end
    ctx.remits_fields.freeze
  end

  def self.stato(p_disp, p_min)
    if p_disp.zero?
      'OFF'
    else
      p_disp < p_min ? 'OFF' : 'ON'
    end
  end

  def self.chk_disp(stato, p_disp, p_max)
    if stato == 'OFF'
      0
    elsif p_disp < p_max
      1
    else
      0
    end
  end
end
