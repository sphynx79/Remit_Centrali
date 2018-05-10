#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module RemitCentrali
  class BaseModel
    attr_reader :client

    def initialize
      Mongo::Logger.level = eval(RemitCentrali::Config.database.log_level)
      @client ||= connect_db
    end

    #
    # Si Connette al server
    #
    # @raise [Mongo::Error::NoServerAvailable] se non riesce a connettersi
    #
    # @note write => 0 nessun acknowledged (pero quando vado fare update o scritture non ho nessun risultato)
    #       write => 1 restituisce un acknowledged (quindi quando faccio update o scritture mi dice il numero di documenti scritti)
    #
    # @return [Mongo::Client]
    #
    def connect_db
      address  = RemitCentrali::Config.database.select { |k, _v| /adress/i =~ k }.values
      database = RemitCentrali::Config.database.name
      client   = Mongo::Client.new(address,
                                   database: database,
                                   server_selection_timeout: 5,
                                   write: { w: 0, j: false }) # @todo vedere se mettere w => 0, setto la modalita' unacknowledged
      client.database_names
      client
    rescue Mongo::Error::NoServerAvailable
      message = <<~MESSAGE
        Non riesco connetermi al db:
        1) Controllare che il server mongodb sia avviato
        2) Controllare in config che IP, PORTA, NOME database siano corretti
      MESSAGE
      message
      # puts 'Cannot connect to the server:'
      # puts '1) Controllare che il server mongodb sia avviato'
      # puts '2) Controllare in config che IP, PORTA, NOME database siano corretti'
      # exit!
    end
  end
end
