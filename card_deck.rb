class CardDeck
  attr_reader :cards
  def initialize
    @cards = fill_card_deck
    # fill_card_deck
  end

  def fill_card_deck
    card_types = %w[2 3 4 5 6 7 8 9 10 В Д К T]
    card_values = [2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, [1, 11]]
    card_suits =  ["\u2660", "\u2663", "\u2665", "\u2666"]
    result_cards = []
    card_suits.each do |suit|
      13.times do |index|
        result_cards << {
          view: "#{card_types[index]}-#{suit}",
          value: card_values[index]
        }
      end
    end
    result_cards
  end
end
