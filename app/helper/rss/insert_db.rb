#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class InsertDb
  extend LightService::Action
  expects :remits, :db, :anagrafica

  executed do |ctx|
    logger.debug('Inserisco le remit a DB')
    collection = ctx.db.collection(collection: RemitCentrali::Config.database.collection)
    update = 0
    insert = 0
    etso_no_censiti = Set[]
    ctx.remits.each do |remit|
      etso = remit[:etso]
      anagrafica_unita = ctx.anagrafica.lazy.select { |f| f['etso'] == etso }.first
      if anagrafica_unita.nil?
        logger.warn("Non ho trovato l'#{etso} in anagrafica, remit non inserita a DB")
        etso_no_censiti << etso 
      else
        remit[:tipo] = anagrafica_unita["tipo"]
        remit[:zona] = anagrafica_unita["zona"]
        result = collection.update_one({ msg_id: remit[:msg_id] }, remit, upsert: true)
        if !result.upserted_count.zero?
          insert += 1
        elsif !result.modified_count.zero?
            update += 1
        end
      end
    end
    logger.debug("Aggiunto #{insert} doc a DB") unless insert.zero?
    logger.debug("Aggiornato #{update} doc a DB") unless update.zero?
    logger.debug('Nessuna remit inserita a DB') if update.zero? && insert.zero?
    send_mail(etso_no_censiti) unless etso_no_censiti.empty?
  end

  def self.send_mail(etso_no_censiti)
    msg = "Non sono state inserite le remit per i seguenti ETSO in quanto non censiti in anagrafica:\n"
    subject = 'Remit: unità non censite in anagrafica'
    etso_no_censiti.each { |etso| msg += "#{etso}\n" }
    RemitCentrali::Mail.call(subject, msg)
  end
end
