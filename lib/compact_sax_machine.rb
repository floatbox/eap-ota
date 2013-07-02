# encoding: utf-8

require 'sax-machine'
require 'active_support/core_ext/string/inflections'

# Обертка над SAXMachine, позволяет вкладывать описания нод друг в друга
# вместо явного задания параметра :class
#
#   class FooNode
#     include CompactSAXMachine
#     elements :bar do
#       element :foo
#     end
#   end
#
# FIXME totally untested

module CompactSAXMachine
  def self.included klass
    klass.send :include, SAXMachine
    klass.extend ClassMethods
  end

  module ClassMethods
    [:elements, :element, :attribute, :value].each do |meth|
      define_method meth do |*args, &definitions|
        if definitions
          node_class = Class.new
          node_class.send :include, CompactSAXMachine
          node_class.class_eval &definitions

          args.push({}) unless args.last.is_a?(Hash)
          args.last[:class] = node_class

          node_class_name = args.first.to_s.camelcase
          const_set node_class_name, node_class
        end
        super *args
      end
    end
  end
end

