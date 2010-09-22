module ActionView
  module Helpers
    class InstanceTag
      DEFAULT_FIELD_OPTIONS = {"size" => nil}
      alias old_tag tag
      def tag(name, options = nil, open = true, escape = true)
        "<#{name}#{tag_options(options, escape) if options}#{open ? ">" : " />"}".html_safe
      end
    end
  end
end