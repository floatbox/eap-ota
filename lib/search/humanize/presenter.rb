# encoding: utf-8

module Search
  module Humanize
    module Presenter
      def details
        return {} unless valid?
        result = {}

        human_parts = []
        person_parts = []
        # FIXME? почему тут нет gettext?
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
          dpt = segment.from_as_object
          arv = segment.to_as_object 
          {
            :title => "#{ dpt.case_from } #{ arv.case_to }",
            :short => "#{ dpt.iata } &rarr; #{ arv.iata }",
            :arvto => "#{ arv.case_to }",
            :arvto_short => "в #{ arv.iata }",
            :date => segment.date,
            :dpt => {:name => dpt.name},
            :arv => {:name => arv.name},
          }
        }
        result[:segments][1][:rt] = true if rt

        result
      end

      def human_short
        if rt
          "#{segments[0].from_as_object.name} &harr; #{segments[0].to_as_object.name}, #{short_date(segments[0].date)} — #{short_date(segments[1].date)}"
        else
          parts = []
          complex = segments.length > 1
          segments.each do |segment|
            if complex
              parts << "#{segment.from_as_object.iata} &rarr; #{segment.to_as_object.iata} #{short_date(segment.date)}"
            else
              parts << "#{segment.from_as_object.name} &rarr; #{segment.to_as_object.name} #{short_date(segment.date)}"
            end
          end
          parts.join(', ')
        end
      end

      def human_locations
        result = {}
        segments.each_with_index do |fs, i|
          if fs.from_as_object && fs.to_as_object
            result['dpt_' + i.to_s] = fs.from_as_object.case_from
            result['arv_' + i.to_s] = fs.to_as_object.case_to
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
    end
  end
end

