# frozen_string_literal: true

require_relative 'gamer'
require_relative 'dealer'
require_relative 'card_deck'

# Main Game class
# rubocop:disable Metrics/ClassLength
class Game
  attr_reader :gamer, :dealer, :card_deck, :bank

  BET_SIZE = 10

  def initialize
    @bank = 0
    @gamer = Gamer.new
    @dealer = Dealer.new
    @card_deck = CardDeck.new
    deal_cards
    make_first_bets
  end

  def start
    take_name_and_initialize
    gamer_turn
  end

  def take_name_and_initialize
    puts "\nДобро пожаловать в игру Black Jack (Thinknetica edition)"
    gamer_name_initialzer
    puts "\n\tСпасибо, #{gamer.name}, для вас начинается игра Black Jack!"
  end

  def gamer_name_initialzer
    return if gamer.name

    print 'Для начала игры введите ваше имя: '
    user_name = gets.chomp
    gamer.name = user_name
  end

  def cards_view_output(user)
    cards = []
    user.cards.each do |card|
      cards << card[:view]
    end
    cards.join(',')
  end

  def gamer_turn
    return finishing_game if game_over?

    gamer_select = prepare_input
    case gamer_select
    when '1'
      skip_gamer_turn
    when '2'
      add_card_to_gamer
    when '3'
      open_cards
    end
  end

  def prepare_input
    puts "\nВаш ход, #{gamer.name}, для вас доступны варианты:"
    show_score_table
    puts "\t1 - Пропустить ход"
    puts "\t2 - Добавить карту"
    puts "\t3 - Открыть карты и подсчитать результаты"
    print 'Введите цифру с вашим выбором: '
    gets.chomp
  end

  def show_score_table
    puts "Ваши карты = #{cards_view_output(gamer)}, "\
      "сумма очков: #{gamer_points}"
    puts "Карты дилера = #{dealer_sanitized_cards}"
  end

  def skip_gamer_turn
    if dealer_points < 17
      puts 'Вы пропустили ход. Ожидаем действий дилера'
      dealer_auto_turn
    else
      puts 'Дилер также пропустил ход, вам необходимо либо добавить карту, '\
        'либо открыть карты и подсчитать результаты'
      gamer_turn
    end
  end

  def dealer_auto_turn
    return finishing_game if game_over?

    take_one_card(dealer) if dealer_points < 17 && dealer.cards.size <= 3
    gamer_turn
  end

  def add_card_to_gamer
    take_one_card(gamer)
    puts "Вам досталась карта #{gamer.cards.last[:view]}"
    puts "Ваши карты = #{cards_view_output(gamer)}, "\
      "сумма очков: #{gamer_points}"
    puts "Карты дилера = #{dealer_sanitized_cards}"
    return finishing_game if game_over?

    dealer_auto_turn
  end

  def open_cards
    puts 'Открываем карты, заканчиваем игру'
    finishing_game
  end

  def game_over?
    gamer.cards.size == 3 &&
      (dealer.cards.size == 3 || dealer_points >= 17)
  end

  def finishing_game
    puts "\nИгра окончена, подсчет очков"
    output_gamers_final_values
    puts "\nПодведение итогов игры"
    bank_distribution(handling_winner)
    output_final_game_status(handling_winner)
    output_account_amounts
    new_game_invite
  end

  def output_gamers_final_values
    puts "Игрок '#{gamer.name}', количество очков: #{gamer_points}, "\
      "карты = #{cards_view_output(gamer)}"
    puts "Дилер, количество очков: #{dealer_points}, "\
      "карты = #{cards_view_output(dealer)}"
  end

  def handling_winner
    final_dealer_points = dealer_points
    final_gamer_points = gamer_points
    return 'standoff' if final_dealer_points == final_gamer_points
    return 'dealer' if final_dealer_points <= 21 && final_gamer_points > 21
    return 'gamer' if final_gamer_points <= 21 && final_dealer_points > 21

    final_dealer_points > final_gamer_points ? 'dealer' : 'gamer'
  end

  def bank_distribution(result)
    case result
    when 'dealer'
      dealer.increase_account(@bank)
    when 'gamer'
      gamer.increase_account(@bank)
    when 'standoff'
      dealer.increase_account(@bank / 2)
      gamer.increase_account(@bank / 2)
    end
    @bank = 0
  end

  def output_account_amounts
    dealer_amount = dealer.account_amount
    gamer_amount = gamer.account_amount
    puts "\nБанковские счета игроков:"
    puts "\tСчет игрока = #{gamer_amount}"
    puts "\tСчет дилера = #{dealer_amount}"
  end

  def output_final_game_status(winner)
    case winner
    when 'dealer'
      puts 'Игра окончилась победой дилера.'
    when 'gamer'
      puts 'Игра окончилась победой игрока.'
    when 'standoff'
      puts 'Игра окончилась в ничью.'
    end
  end

  def new_game_invite
    puts "\nЖелаете сыграть еще партию?"
    puts '1 - да'
    puts '2 - нет'
    print('Введите ваш ответ: ')
    user_choice = gets.chomp
    user_choice_hanling(user_choice)
  end

  def user_choice_hanling(user_choice)
    case user_choice
    when '1'
      start_new_game
    when '2'
      puts 'Благодарим за игру, будем рады видеть вас снова!'
    end
  end

  def start_new_game
    if gamer.account_amount < 10
      puts 'Извините, у вас больше нет денег для игры, зарабатывайте и приходите играть снова!'
    else
      puts 'Ожидайте, новая игра подготавливается'
      sleep 0.75
      create_new_game
    end
  end

  def create_new_game
    @card_deck = CardDeck.new
    dealer.clear_cards
    gamer.clear_cards
    deal_cards
    make_first_bets
    start
  end

  def dealer_sanitized_cards
    cards = []
    dealer.cards.size.times { cards << '*' }
    cards.join(',')
  end

  def take_one_card(player)
    player.take_card(card_deck.take_random_card)
  end

  private

  def dealer_points
    dealer.calculate_card_points
  end

  def gamer_points
    gamer.calculate_card_points
  end

  def deal_cards
    2.times do
      gamer.take_card(card_deck.take_random_card)
      dealer.take_card(card_deck.take_random_card)
    end
  end

  def make_first_bets
    @bank += BET_SIZE if dealer.make_bet(BET_SIZE)
    @bank += BET_SIZE if gamer.make_bet(BET_SIZE)
  end
end
# rubocop:enable Metrics/ClassLength

game = Game.new
game.start
