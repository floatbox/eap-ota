# encoding: utf-8

module Search
  module Humanize
    module Presenter
      def details
        return {} unless valid?
        result = {}

        human_parts = []
        person_parts = []
        if adults > 1
          person_parts << ['вдвоем', 'втроем', 'вчетвером', 'впятером', 'вшестером', 'всемером', 'ввосьмером'][adults-2]
        end
        if children > 0
          person_parts << ['с&nbsp;ребенком', 'с&nbsp;двумя детьми', 'с&nbsp;тремя детьми', 'с&nbsp;четырьмя детьми', 'с&nbsp;пятью детьми', 'с&nbsp;шестью детьми', 'с&nbsp;семью детьми'][children-1]
        end
        person_parts << 'и' if infants > 0 && children > 0
        if infants > 0
          person_parts << ['с&nbsp;младенцем', 'с&nbsp;двумя младенцами', 'с&nbsp;тремя младенцами', 'с&nbsp;четырьмя младенцами', 'с&nbsp;пятью младенцами', 'с&nbsp;шестью младенцами', '7 младенцев'][infants-1]
        end
        unless person_parts.empty?
          human_parts << person_parts.join(' ')
        end

        case cabin
        when 'C'
          human_parts << 'бизнес-классом'
        when 'F'
          human_parts << 'первым классом'
        end

        result[:options] = {
          :adults => adults,
          :children => children,
          :infants => infants,
          :total => adults + children + infants,
          :cabin => cabin,
          :human => human_parts.join(', ')
        }

        result[:segments] = segments.map{|segment|
          dpt = segment.from
          arv = segment.to 
          {
            :title => "#{ dpt.case_from } #{ arv.case_to }",
            :short => "#{ dpt.iata } &rarr; #{ arv.iata }",
            :arvto => "#{ arv.case_to }",
            :arvto_short => "в #{ arv.iata }",
            :date => segment.date_for_render,
            :dpt => {:name => dpt.name},
            :arv => {:name => arv.name},
          }
        }
        result[:segments][1][:rt] = true if rt

        result
      end

      def human_short
        if rt
          "#{segments[0].from.name} &harr; #{segments[0].to.name}, #{segments[0].short_date} — #{segments[1].short_date}"
        else
          parts = []
          complex = segments.length > 1
          segments.each do |segment|
            if complex
              parts << "#{segment.from.iata} &rarr; #{segment.to.iata} #{segment.short_date}"
            else
              parts << "#{segment.from.name} &rarr; #{segment.to.name} #{segment.short_date}"
            end
          end
          parts.join(', ')
        end
      end

      def human_locations
        result = {}
        segments.each_with_index do |fs, i|
          if fs.from && fs.to
            result['dpt_' + i.to_s] = fs.from.case_from
            result['arv_' + i.to_s] = fs.to.case_to
          end
        end
        result
      end

      def human_date(ds)
        d = Date.strptime(ds, '%d%m%y')
        if d.year == Date.today.year
          return I18n.l(d, :format => '%e&nbsp;%B')
        else
          return I18n.l(d, :format => '%e&nbsp;%B %Y')
        end
      end

      def human_lite
        segments[0].from.name + (rt ? ' ⇄ ' : ' → ') + segments[0].to.name
      end

    end
  end
end

