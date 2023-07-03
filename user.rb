# frozen_string_literal: true

require_relative 'card_deck'
require 'pry'

# Base user class
class User
  attr_reader :account_amount, :cards
  attr_accessor :ace_counter, :name

  def initialize(*)
    @account_amount = 100
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
    return @simple_cards_value if ace_counter.zero?

    max_value = 0
    ace_values(@ace_counter).each do |ace_value|
      temp_result = @simple_cards_value + ace_value
      max_value = temp_result if temp_result <= 21 && temp_result > max_value
    end
    max_value
  end

  private
  
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
