# frozen_string_literal: true

module SitePrism
  module ElementChecker
    def all_there?
      self.class.mapped_items.each_key.all? { |element| has?(element) }
    end
  end
end
