#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

require 'net/smtp'

module RemitCentrali
  class Mail
    class << self
      attr_accessor :server, :port, :from, :to, :subject, :msg, :marker

      def call(subject, msg)
        @server = RemitCentrali::Config.mail.server
        @port = RemitCentrali::Config.mail.port
        @from = RemitCentrali::Config.mail.from
        @to = RemitCentrali::Config.mail.to
        @subject = "#{subject} #{DateTime.now.strftime('%d-%m-%Y %H:%M')}"
        @marker  = 'AUNIQUEMARKER'
        @msg     = msg
        send
      end

      def send
        head = make_head
        # match_attach = make_attach(match_path)
        # nomatch_attach = make_attach(nomatch_path)
        body = make_body

        msg = head + body
        begin
          Net::SMTP.start(server, port) do |smtp|
            smtp.send_message msg, from, to
          end
          logger.debug 'Email Inviata'
        rescue StandardError
          logger.warn("Errore nell'invio dell'email")
        end
      end

      def make_head
        <<~MAIL
          From: #{from}
          To: #{to}
          Subject: #{subject}
          MIME-Version: 1.0
          Content-Type: multipart/mixed; boundary=#{marker}
          --#{marker}
        MAIL
      end

      def make_body
        <<~HTML
          Content-Type: text/plain; charset=UTF-8

          #{msg}
          --#{marker}--
        HTML
      end
    end
  end
end
