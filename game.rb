class Game
  def start
    puts "Добро пожаловать в игру Black Jack (Thinknetica edition)"
    print "Для начала игры введите ваше имя: "
    user_name = gets.chomp
    puts "Спасибо, #{user_name}, для вас начинается игра Black Jack!"
  end

  private

  def show_menu
  end
end

Game.new.start