# encoding: utf-8

# ускоренная версия RSpec::Core::Let
# вызывается один раз на scope
# использовать только для read_only объектов!
# создает опасность, что тест номер1 может
# изменить созданный let_once! объект и повлиять на
# результат теста номер2
module SpecExtensions
  module LetOnce
    module ClassMethods
      def let_once!(name, &block)
        define_method(name) do
          instance_variable_get("@#{name}")
        end
        before(:all){ instance_variable_set("@#{name}", instance_eval(&block)) }
      end

      def subject_once!( &block )
        let_once!( :__memoized_once_subject, &block )
        subject { __memoized_once_subject }
      end
    end

    module InstanceMethods
      #def __memoized_once # :nodoc:
      #  @__memoized_once ||= {}
      #end
    end

    def self.included(mod) # :nodoc:
      mod.extend ClassMethods
      mod.__send__ :include, InstanceMethods
    end
  end
end
