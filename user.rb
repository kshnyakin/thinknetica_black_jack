class User
  attr_reader :account_amount
  def initialize(*)
    @account_amount = 100
  end

  def make_bet
    @account_amount -= 10 if @account_amount >= 10
  end
end