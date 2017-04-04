class DepositNotifier < ApplicationMailer

  def send_notification(deposit)
    @deposit = deposit
    mail(to: 'fcd1@columbia.edu', subject: 'This is a test from sword')
  end
end
