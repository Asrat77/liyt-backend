class DeliveryMailer < ApplicationMailer
  def confirmation_email(delivery, recipient_email)
    @delivery = delivery
    @business = delivery.business
    @pickup_stop = delivery.pickup_stop
    @items = delivery.delivery_items
    @tracking_token = delivery.delivery_tracking_token
    @confirmation_url = generate_confirmation_url

    mail(
      to: recipient_email,
      subject: "New Delivery from #{@business&.name || "LIYT"}"
    )
  end

  private

  def generate_confirmation_url
    base_url = ENV.fetch("FRONTEND_URL", "https://liyt.com")
    "#{base_url}/confirm-delivery?token=#{@tracking_token&.token_hash}"
  end
end
