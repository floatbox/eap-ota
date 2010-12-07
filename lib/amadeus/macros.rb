module Amadeus
  module Macros

    def pnr_retrieve_and_ignore(args)
      pnr_retrieve(args)
    ensure
      pnr_ignore
    end

    # PNR, как он виден в системе
    def pnr_raw(pnr_number)
      cmd_full("RT#{pnr_number}") rescue $!.message
    ensure
      pnr_ignore
    end

    def pnr_ignore
      pnr_add_multi_elements :ignore => true
    end

    def pnr_ignore_and_retrieve
      # сделать опцию для pnr_add_multi_elements
      cmd("IR")
    end

    def pnr_commit
      pnr_add_multi_elements :end_transact => true
    end

    def pnr_commit_and_retrieve
      # сделать опцию для pnr_add_multi_elements
      cmd("ER")
    end

    def pnr_cancel
      cmd('XI')
    end

    def pnr_archive(seats)
      # 11 месяцев по каким-то причинам не сработало. +10
      monthplus10 =
        %W(JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC)[(Time.now.month-1 + 10) % 12]
      cmd("RU1AHK#{seats}MOW1#{monthplus10}")
    end

    # FIXME спросить как на самом деле надо
    def pnr_carrier_locator
      cmd('RL').lines.to_a[2] =~ /^..\/([A-Z\d]{6})/
      $1
    end

    def cmd(command)
      response = command_cryptic :command => command
      response.xpath('//r:textStringDetails').to_s
    end

    # работает только для очень некоторых команд
    def cmd_full(command)
      result = cmd(command)
      # заголовок
      result.sub!(/^(.*)\n/, '');
      if $1 == '/'
        # FIXME сделать класс для эксепшнов
        raise "Command_Cryptic: #{result.strip}"
      end
      # добываем следующие страницы, если есть
      while result.sub! /^\)\s*\Z/, ''
        # не обрезает заголовок второй и последующих страниц.
        # но разные команды выводят или не выводят в нем муру, эх
        result << cmd('MD')[2..-1]
      end
      result
    end

    # временное название для метода
    # WARNING - использует отдельную сессию!
    def issue_ticket(pnr_number)
      amadeus = Amadeus::Service.new(:book => true, :office => Amadeus::Session::TICKETING)
      amadeus.pnr_retrieve(:number => pnr_number)
      amadeus.doc_issuance_issue_ticket.bang!
    ensure
      amadeus.session.destroy
    end

    def give_permission_to_ticketing_office
      cmd("ES #{Amadeus::Session::TICKETING}-B")
    end

    def conversion_rate(currency_code)
      # BSR USED 1 USD = 30.50 RUB
      cmd("FQC 1 #{currency_code}") =~ /^BSR USED 1 ...? = ([\d.]+) RUB/
      $1.to_f if $1
    end

  end
end
