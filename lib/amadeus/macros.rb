# encoding: utf-8
module Amadeus
  module Macros

    def pnr_retrieve_and_ignore(args)
      pnr_retrieve(args)
    ensure
      pnr_ignore
    end

    # PNR, как он виден в системе
    def pnr_raw(pnr_number)
      cmd_full("RT#{pnr_number}", true) rescue $!.message
    ensure
      # временно не нужно - все равно сессию закрываем
      # pnr_ignore
    end

    def ticket_raw(ticket_number)
      result = ""
      result << (cmd_full("TWD/TKT #{ticket_number}", true) rescue $!.message)
      result << "\n\n"
      result << (cmd_full("TWD/TAX") rescue $!.message)
      result
    ensure
      # опять же, временно не нужно - все равно сессию закрываем
      # впрочем, данная команда не оставляет бронь открытой
      # pnr_ignore
    end

    def pnr_ignore
      pnr_add_multi_elements :pnr_action => :IG
    end

    def pnr_ignore_and_retrieve
      pnr_add_multi_elements :pnr_action => :IR
    end

    def pnr_commit
      pnr_add_multi_elements :pnr_action => :ET
    end

    def pnr_commit_and_retrieve
      pnr_add_multi_elements :pnr_action => :ER
    end

    # сохраняет pnr!
    def pnr_commit_really_hard
      yield
      result = pnr_commit_and_retrieve
      # закоммитить такое не удастся. надо повторять
      if result.error_message == "SIMULTANEOUS CHANGES TO PNR - USE WRA/RT TO PRINT OR IGNORE"
        pnr_ignore_and_retrieve
        yield
        result = pnr_commit_and_retrieve
      end
      # ER;ER трюк - двойной коммит для обхода ворнингов
      unless result.success?
        pnr_commit_and_retrieve
      end
      # если и сейчас не вышло - не судьба!
    end

    # FIXME спросить как на самом деле надо
    def pnr_carrier_locator
      cmd('RL').lines.to_a[2] =~ /^..\/([A-Z\d]{6})/
      $1
    end

    def cmd(command)
      raise "you really want dedicated session" unless session
      response = command_cryptic :command => command
      response.xpath('//r:textStringDetails').to_s
    end

    class CommandCrypticError < RuntimeError; end

    # работает только для очень некоторых команд
    def cmd_full(command, scroll_pnr=false)
      result = cmd(command)
      # заголовок
      result.sub!(/^(.*)\n/, '');
      if $1 == '/'
        # FIXME сделать класс для эксепшнов
        raise CommandCrypticError, result.strip
      end
      # добываем следующие страницы, если есть
      while result.sub! /^\)\s*\Z/, ''
        # не обрезает заголовок второй и последующих страниц.
        # но разные команды выводят или не выводят в нем муру, эх
        result << cmd(scroll_pnr ? 'MDR' : 'MD')[2..-1]
      end
      result
    end

    # временное название для метода
    # WARNING - использует отдельную сессию!
    def issue_ticket(pnr_number)
      Amadeus.ticketing do |amadeus|
        amadeus.pnr_retrieve(:number => pnr_number)
        amadeus.doc_issuance_issue_ticket.or_fail!
      end
    end

    def give_permission_to_offices *office_ids
      cmd("ES " + office_ids.map{|id| "#{id}-B"}.join(','))
    end

    def conversion_rate(currency_code)
      # BSR USED 1 USD = 30.50 RUB
      cmd("FQC 1 #{currency_code}") =~ /^BSR USED 1 ...? = ([\d.]+) RUB/
      $1.to_f if $1
    end

    def interline_iatas(company_iata)
      cmd_full("TGAD-#{company_iata}") \
        .split(/\s*-\s+/) \
        .collect {|s| s.split(' ', 2) } \
        .select {|carrier, agreement| agreement['E'] && !agreement['*']} \
        .collect {|carrier,_| carrier}
    end
  end
end

