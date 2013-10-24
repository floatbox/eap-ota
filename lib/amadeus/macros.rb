# encoding: utf-8
module Amadeus
  module Macros

    # В отличие от pnr_ingore_and_retrieve, достает не текущий, а произвольный PNR.
    def pnr_retrieve_and_ignore(args)
      pnr_retrieve(args)
    ensure
      pnr_ignore
    end

    # PNR, как он виден в системе. Без аргументов покажет текущий.
    def pnr_raw(pnr_number='')
      cmd_full("RT#{pnr_number}", true) rescue $!.message
    ensure
      # временно не нужно - все равно сессию закрываем
      # pnr_ignore
    end

    # история текущего PNR, как она видна в системе.
    def pnr_history_raw
      cmd_full("RH/ALL", true) rescue $!.message
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

    # Не сохраняет последние изменения и закрывает PNR.
    def pnr_ignore
      pnr_add_multi_elements :pnr_action => :IG
    end

    # Не сохраняет последние изменения, оставляет PNR открытым.
    def pnr_ignore_and_retrieve
      pnr_add_multi_elements :pnr_action => :IR
    end

    # Сохраняет изменения, закрывает PNR.
    def pnr_commit
      pnr_add_multi_elements :pnr_action => :ET
    end

    # Сохраняет изменения, оставляет PNR открытым.
    def pnr_commit_and_retrieve
      pnr_add_multi_elements :pnr_action => :ER
    end

    # Удаляет полетные сегменты и закрывает PNR.
    def pnr_cancel_itinerary(opts={})
      pnr_cancel opts.reverse_merge(itinerary: true, pnr_action: :ET)
    end

    # Выполняет блок и сохраняет PNR (оставляет PNR открытым в сессии).
    # В случае однократного отказа сохранять PNR из-за одновременного изменения
    # авиакомпаниями пробует сохранить еще ровно один раз!
    # Возвращает pnr reply.
    # Имеет смысл делать .or_fail! на случай невозможности сохранить и со второй попытки
    def pnr_commit_really_hard
      yield
      result = pnr_commit_and_retrieve
      # закоммитить такое не удастся. надо повторять
      if result.error_message && result.error_message["SIMULTANEOUS CHANGES TO PNR - USE WRA/RT TO PRINT OR IGNORE"]
        #FIXME добавить логгинг
        pnr_ignore_and_retrieve
        yield
        result = pnr_commit_and_retrieve
      end
      return result if result.success?
      # ER;ER трюк - двойной коммит для обхода ворнингов
      pnr_commit_and_retrieve
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

    # похоже на cmd_full, но лучше всего работает с HELP
    def cmd_full_help(command)
      pages = [cmd(command)]
      until pages.last['*** END OF DISPLAY ***']
        new_page = cmd('MD')
        break if new_page == pages.last
        pages << new_page
      end

     # зачем-то после каждой строки возвращается пробел
     pages.map! { |p| p.gsub "\n ", "\n" }
     # заголовок повторяется обычно, убираем
     header = pages.first.lines.first.sub(/^\/\$/, '')
      pages.map! {|page|
        page.lines
          .drop(1)
          .reject{|l| l == " (PARTIAL DISPLAY)\n"}
          .each {|l| l.sub!(/ +MD$/, '') if l.rindex(' MD') == 60 }
          .join
      }
      # обрезание возможного повтора на последней неполной странице
      if pages.size > 1
        lbup, lp = pages[-2,2]
        # 2..последняя строчка, 3..последняя строчка, и т.п.
        lbup.scan(/\n(?=(.+))/m) do |part, *|
          lp.start_with?(part) and lp.sub!(part, '') and break
        end
      end
      pages.last.sub! /\s*\*\*\* END OF DISPLAY \*\*\*\Z/, ''
      ([header] + pages).join
    end

    # временное название для метода
    # WARNING - использует отдельную сессию!
    def issue_ticket(pnr_number)
      Amadeus.ticketing do |amadeus|
        amadeus.pnr_retrieve(:number => pnr_number)
        amadeus.doc_issuance_issue_ticket.or_fail!
      end
    end

    def conversion_rate(from, to = 'RUB', date = Date.today)
      # BSR USED 1 USD = 30.50 RUB
      cmd("FQC 1 #{from}/#{to}/#{date.strftime('%d%b%y')}") =~ /^BSR USED 1 ...? = ([\d+.\d]+) #{to}/
      if $1
        return $1.to_f
      elsif !Conf.amadeus.check_rate_date
        # нужно, тк тестовые амедеус живет в прошлом
        cmd("FQC 1 #{from}/#{to}") =~ /^BSR USED 1 ...? = ([\d+.\d]+) #{to}/
        return $1.to_f if $1
      end
      raise "Error getting amadeus rate for date: #{date.strftime('%d%b%y')}"
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

