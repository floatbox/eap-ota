module Traviata
  module ActiveRecordExt
    module ClassMethods

      PREPOSITIONS_TO_REGEX = /\b(#{ %W(в во на до к).join('|') })\b\s+/
      PREPOSITIONS_FROM_REGEX = /\b(#{ %W(из c).join('|') })\b\s+/

      def has_prefixed_scope args
        prefixed = Array(args[:prefix])
        full = Array(args[:full])

        #condition = (
        #  full.map {|field| "#{field} = ?"} +
        #  prefixed.map {|field| "#{field} like ?"}
        #).join(' or ')

        #named_scope :prefixed, lambda { |word|
        #  prefix = "#{word}%"
        #  { :conditions => [condition] + [word]*full.size + [prefix]*prefixed.size }
        #}

        # понять, как сюда привинтить префиксы всякие
        # перенести логику стопвордов уровнем куда-то повыше?
        def self.prefixed original_string

          text_to_be_replaced = original_string.gsub(QueryParser.known_words_regex, '').strip

          word = text_to_be_replaced.dup

          if word.sub! PREPOSITIONS_TO_REGEX, ''
            completion_case = :to
          elsif word.sub! PREPOSITIONS_FROM_REGEX, ''
            completion_case = :from
          end

          # решает проблему с "Нью-Йорк и Санкт-Петербург"
          word.gsub! '-', ' '

          if word.gsub(' ','').length < 3
            results = []
          else
            results = search("(#{word}) | (#{word}*)", :match_mode => :extended, :order => :importance, :sort_mode => :desc)
            results.each do |r|
              word_completion = r.completion_for(completion_case)
              r.completion = original_string.sub(text_to_be_replaced, word_completion)
            end
          end

          results
        end

      end

      def has_cases_for attribute
        class_eval <<-"END", __FILE__, __LINE__
          def nominative
            #{attribute}
          end
          include Traviata::ActiveRecordExt::Cases
        END
      end

    end

    module Cases

      def cases
        inflections = MorpherInflect.inflections( nominative )
        # попытка обойти странности склонений одушевленных объектов
        if nominative.present? && !nominative[/[ая]$/]
          inflections[3] = inflections[0]
        end
        inflections
      end

      def guessed_to
        "в #{cases[3] || nominative}"
      end

      def guessed_from
        "из #{cases[1] || nominative}"
      end

      def guessed_in
        "в #{cases[5] || nominative}"
      end

      def case_to
        proper_to.present? ? proper_to : guessed_to
      end

      def case_from
        proper_from.present? ? proper_from : guessed_from
      end

      def case_in
        proper_in.present? ? proper_in : guessed_in
      end

      def case_to=(str)
        if str.present? && str != guessed_to
          self.proper_to = str
        else
          self.proper_to = nil
        end
      end

      def case_from=(str)
        if str.present? && str != guessed_from
          self.proper_from = str
        else
          self.proper_from = nil
        end
      end

      def case_in=(str)
        if str.present? && str != guessed_in
          self.proper_in = str
        else
          self.proper_in = nil
        end
      end
      
      def splitted_case_in
        a = case_in.split ' '
        [a[0], a[1..-1].join(' ')]
      end

      attr_accessor :completion

      def completion_for case_symbol
        case case_symbol
        when :to
          case_to
        when :from
          case_from
        else
          nominative
        end
      end
    end
  end
end

ActiveRecord::Base.send :extend, Traviata::ActiveRecordExt::ClassMethods
