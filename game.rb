require 'pry'
require_relative 'gamer'
require_relative 'dealer'
require_relative 'card_deck'

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
    puts "Добро пожаловать в игру Black Jack (Thinknetica edition)"
    unless self.gamer.name
      print "Для начала игры введите ваше имя: "
      user_name = gets.chomp
      self.gamer.name = user_name
    end
    puts "\n\tСпасибо, #{self.gamer.name}, для вас начинается игра Black Jack!"
    puts "Ваши карты = #{cards_view_output(self.gamer)}, "\
         "сумма очков: #{self.gamer.calculate_card_points}"
    puts "Карты дилера = #{dealer_sanitized_cards}"
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
    puts "\nВаш ход, #{self.gamer.name}, для вас доступны варианты:"
    puts "\t1 - Пропустить ход"
    puts "\t2 - Добавить карту"
    puts "\t3 - Открыть карты и подсчитать результаты"
    print "Введите цифру с вашим выбором: "
    gamer_select = gets.chomp
    case gamer_select
    when '1'
      skip_gamer_turn
    when '2'
      add_card_to_gamer
    when '3'
      open_cards
    end
  end

  def skip_gamer_turn
    puts 'Вы пропустили ход. Ожидаем действия дилера'
    dealer_auto_turn
  end

  def dealer_auto_turn
    return finishing_game if game_over?
    points = self.dealer.calculate_card_points
    if points >= 17
      gamer_turn
    else
      take_one_card(self.dealer)
      gamer_turn
    end
  end

  def add_card_to_gamer
    card = take_one_card(self.gamer)
    puts "Вам досталась карта #{self.gamer.cards.last[:view]}"
    puts "Ваши карты = #{cards_view_output(self.gamer)}, "\
      "сумма очков: #{self.gamer.calculate_card_points}"
    puts "Карты дилера = #{dealer_sanitized_cards}"
    return finishing_game if game_over?
    dealer_auto_turn
  end

  def open_cards
    puts "Открываем карты, заканчиваем игру"
    finishing_game
  end

  def game_over?
    self.gamer.cards.size == 3 && 
    (self.dealer.cards.size == 3 || self.dealer.calculate_card_points >= 17)
  end

  def finishing_game
    puts "\nИгра окончена, подсчет очков"
    puts "Игрок '#{self.gamer.name}', количество очков: #{self.gamer.calculate_card_points}, "\
      "карты = #{cards_view_output(self.gamer)}"
    puts "Дилер, количество очков: #{self.dealer.calculate_card_points}, "\
      "карты = #{cards_view_output(self.dealer)}"
    puts "\nПодведение итогов игры (handling_winner method)"
    puts "the winner is #{handling_winner}"
    bank_distribution(handling_winner)
    output_account_amounts
    new_game_invite
  end

  def handling_winner
    dealer_points = self.dealer.calculate_card_points
    gamer_points = self.gamer.calculate_card_points
    return 'standoff' if (dealer_points == gamer_points) && (dealer_points <= 21)
    return 'dealer' if dealer_points <= 21 && gamer_points > 21
    return 'gamer' if gamer_points <= 21 && dealer_points > 21
    dealer_points > gamer_points ? 'dealer' : 'gamer'
  end

  def bank_distribution(result)
    bank_value = @bank
    @bank = 0
    case result
    when 'dealer'
      self.dealer.increase_account(bank_value)
    when 'gamer'
      self.gamer.increase_account(bank_value)
    when 'standoff'
      self.dealer.increase_account(bank_value / 2)
      self.gamer.increase_account(bank_value / 2)
    end
  end

  def output_account_amounts
    dealer_amount = self.dealer.account_amount
    gamer_amount = self.gamer.account_amount
    puts "\tСчет игрока = #{gamer_amount}"
    puts "\tСчет дилера = #{dealer_amount}"
  end

  def new_game_invite
    puts "\nЖелаете сыграть еще партию?"
    puts "1 - да"
    puts "2 - нет"
    print ('Введите ваш ответ: ')
    user_choice = gets.chomp
    case user_choice
    when '1'
      if self.gamer.account_amount < 10
        puts "Извините, у вас больше нет денег для игры, зарабатывайте и приходите играть снова!"
      else
        puts "Ожидайте, новая игра подготавливается"
        sleep 2
        create_new_game
      end
    when '2'
      puts "Благодарим за игру, будем рады видеть вас снова!"
    end
  end

  def create_new_game
    @card_deck = CardDeck.new
    self.dealer.clear_cards
    self.gamer.clear_cards
    deal_cards
    make_first_bets
    start
  end


  def dealer_sanitized_cards
    cards = []
    self.dealer.cards.size.times{ cards << "*"}
    cards.join(',')
  end

  def take_one_card(player)
    player.take_card(card_deck.take_random_card)
  end

  private

  def deal_cards
    2.times do
      gamer.take_card(card_deck.take_random_card)
      dealer.take_card(card_deck.take_random_card)
    end
  end

  def make_first_bets
    # без @ переменная экземпляра bank почему-то определяется как nil,
    # хотя в initialize она определена как 0
    @bank += BET_SIZE if dealer.make_bet(BET_SIZE)
    @bank += BET_SIZE if gamer.make_bet(BET_SIZE)
  end

  def show_menu
  end

end

game = Game.new
game.start

