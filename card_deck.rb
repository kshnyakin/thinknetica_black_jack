require 'pry'

class CardDeck
  attr_reader :cards
  def initialize
    @cards = fill_card_deck
    # fill_card_deck
  end

  def take_random_card
    cards.delete_at(rand(0..cards.size-1)) if cards.size > 0
  end

  private

  def fill_card_deck
    card_types = %w[2 3 4 5 6 7 8 9 10 В Д К T]
    card_slugs = %w[
      two three four five six seven eight nine ten jack lady king ace
    ]
    card_values = [2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, [1, 11]]
    card_suits = ["\u2660", "\u2663", "\u2665", "\u2666"]
    card_suits_slugs = %w[spade cross heart diamond]
    result_cards = []
    card_suits.each_with_index do |suit, suit_index|
      13.times do |index|
        # binding.pry
        result_cards << {
          view: "#{card_types[index]}-#{suit}",
          value: card_values[index],
          slug: "#{card_slugs[index]}-#{card_suits_slugs[suit_index]}"
        }
      end
    end
    result_cards
  end
end
