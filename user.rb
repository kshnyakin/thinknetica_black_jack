require_relative 'card_deck'
require 'pry'

class User
  attr_reader :account_amount, :cards
  attr_accessor :ace_counter, :name

  def initialize(*)
    @account_amount = 10
    @cards = []
    @ace_counter = 0
    @simple_cards_value = 0
  end

  def make_bet(bet_size)
    @account_amount -= bet_size if @account_amount >= bet_size
  end

  def clear_cards
    @cards = []
    @ace_counter = 0
    @simple_cards_value = 0
  end

  def take_card(card)
    cards << card
    if card[:slug].split('-')[0] == 'ace'
      @ace_counter += 1 if card[:slug].split('-')[0] == 'ace'
    else
      @simple_cards_value += card[:value]
    end
  end

  def increase_account(value)
    @account_amount += value
  end

  def calculate_card_points
    # puts "карты пользователя: #{@cards}"
    return @simple_cards_value if ace_counter.zero?
    # puts "\nварианты значения тузов: #{ace_values(@ace_counter)}"
    # puts "текущий счет по обычным картам: #{@simple_cards_value}"
    max_value = 0
    ace_values(@ace_counter).each do |ace_value|
      temp_result = @simple_cards_value + ace_value
      max_value = temp_result if (temp_result <= 21 && temp_result > max_value)
    end
    max_value
  end

  def ace_values(quantity)
    case quantity
    when 1
      [1, 11]
    when 2
      [2, 12]
    when 3
      [3, 13]
    end
  end

end

# deck = CardDeck.new;
# user = User.new;
# user.take_card(deck.cards[12]) # добавили туза
# user.take_card(deck.cards[11]) # добавили короля (10)

# user.take_card(deck.cards[8]) # добавили 10-ку
# user.take_card(deck.cards[21]) # добавили 10-ку
# user.take_card(deck.cards[34]) # добавили 10-ку

# user.calculate_card_points # подсчитать очки
# user.take_card(deck.cards[25]) # добавить второго туза
# user.take_card(deck.cards[38]) # добавить третьего туза

# binding.pry