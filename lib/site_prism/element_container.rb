# frozen_string_literal: true

module SitePrism
  module ElementContainer
    def self.included(base)
      base.extend(ClassMethods)
    end

    def has?(element_name, *args)
      selector = selector_for(element_name) { raise_no_selector(element_name) }
      wait_time = SitePrism.use_implicit_waits ? Waiter.default_wait_time : 0
      Capybara.using_wait_time wait_time do
        element_exists?(*selector, *args)
      end
    end

    def has_no?(element_name, *args)
      selector_for(element_name) { return true }
      !has?(element_name, *args)
    end

    def wait_for(element_name, timeout = nil, *args)
      selector = selector_for(element_name) { raise_no_selector(element_name) }
      timeout = timeout.nil? ? Waiter.default_wait_time : timeout
      Capybara.using_wait_time timeout do
        element_exists?(*selector, *args)
      end
    end

    def wait_until_visible(element_name, timeout = Waiter.default_wait_time, *args)
      selector = selector_for(element_name) { raise_no_selector(element_name) }
      Timeout.timeout timeout, SitePrism::TimeOutWaitingForElementVisibility do
        Capybara.using_wait_time 0 do
          sleep 0.05 until element_exists?(*selector, *args, visible: true)
        end
      end
    end

    def wait_until_invisible(element_name, timeout = Waiter.default_wait_time, *args)
      selector = selector_for(element_name) { raise_no_selector(element_name) }
      Timeout.timeout timeout, SitePrism::TimeOutWaitingForElementInvisibility do
        Capybara.using_wait_time 0 do
          sleep 0.05 while element_exists?(*selector, *args, visible: true)
        end
      end
    end

    private

    def selector_for(element_name)
      selector = self.class.mapped_items[element_name.to_s] || []
      yield if selector.empty?
      selector
    end

    def fetch_element_find_args(name)
      find_args = self.class.mapped_items.fetch(name.to_s, [])
      raise_no_selector(name) if find_args.empty?
      find_args
    end

    def raise_no_selector(element_name)
      raise SitePrism::NoSelectorForElement.new, "#{self.class.name} => :#{element_name} needs a selector"
    end

    module ClassMethods
      def element(element_name, *find_args)
        build element_name, *find_args do
          define_method element_name.to_s do |*runtime_args, &element_block|
            self.class.raise_if_block(self, element_name.to_s, !element_block.nil?)
            find_first(*find_args, *runtime_args)
          end
        end
      end

      def elements(collection_name, *find_args)
        build collection_name, *find_args do
          define_method collection_name.to_s do |*runtime_args, &element_block|
            self.class.raise_if_block(self, collection_name.to_s, !element_block.nil?)
            find_all(*find_args, *runtime_args)
          end
        end
      end
      alias collection elements

      def section(section_name, *args, &block)
        section_class, find_args = extract_section_options args, &block
        build section_name, *find_args do
          define_method section_name do |*runtime_args, &runtime_block|
            section_class.new self, find_first(*find_args, *runtime_args), &runtime_block
          end
        end
      end

      def sections(section_collection_name, *args, &block)
        section_class, find_args = extract_section_options args, &block
        build section_collection_name, *find_args do
          define_method section_collection_name do |*runtime_args, &element_block|
            self.class.raise_if_block(self, section_collection_name.to_s, !element_block.nil?)
            find_all(*find_args, *runtime_args).map do |element|
              section_class.new self, element
            end
          end
        end
      end

      def iframe(iframe_name, iframe_page_class, selector)
        element_selector = deduce_iframe_element_selector(selector)
        scope_selector = deduce_iframe_scope_selector(selector)
        mapped_items[iframe_name.to_s] = element_selector
        define_method iframe_name do |&block|
          within_frame scope_selector do
            block.call iframe_page_class.new
          end
        end
      end

      def mapped_items
        @mapped_items ||= {}
      end

      def raise_if_block(obj, name, has_block)
        return unless has_block
        raise SitePrism::UnsupportedBlock, "#{obj.class}##{name} does not accept blocks, did you mean to define a (i)frame?"
      end

      private

      def build(name, *find_args)
        if find_args.empty?
          define_method(name) { raise_no_selector(name) }
        else
          mapped_items[name.to_s] = find_args
          yield
        end
      end

      def create_helper_method(proposed_method_name, *find_args)
        if find_args.empty?
          define_method(proposed_method_name) { raise_no_selector(proposed_method_name) }
          create_no_selector proposed_method_name
        else
          yield
        end
      end

      def deduce_iframe_scope_selector(selector)
        selector.is_a?(Integer) ? selector : selector.split('#').last
      end

      def deduce_iframe_element_selector(selector)
        selector.is_a?(Integer) ? "iframe:nth-of-type(#{selector + 1})" : selector
      end

      def extract_section_options(args, &block)
        if args.first.is_a?(Class)
          section_class = args.shift
        elsif block_given?
          section_class = Class.new SitePrism::Section, &block
        else
          raise ArgumentError, 'You should provide section class either as a block, or as the second argument'
        end
        return section_class, args
      end
    end
  end
end
