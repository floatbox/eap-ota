module Sirena
  class Adapter
    class << self
      # Be careful. Should be confirmed or cancelled in 15 minutes
      def book_for_data(order_data)
        recommendation = order_data.recommendation
        response = Sirena::Service.booking(order_data)
        if response.success? && response.pnr_number
          if recommendation.price_fare != response.price_fare ||
             recommendation.price_tax != response.price_tax
            order_data.errors.add :pnr_number, 'Ошибка при создании PNR'
            Sirena::Service.booking_cancel(response.pnr_number, response.lead_family)
          else
            payment_query = Sirena::Service.payment_ext_auth(:query, response.pnr_number, response.lead_family)
            if payment_query.success? && payment_query.cost
              if payment_query.cost == recommendation.price_fare + recommendation.price_tax
                order_data.pnr_number = response.pnr_number
                order_data.sirena_lead_pass = response.lead_family
                order_data.order = Order.create(:order_data => order_data)
              else
                order_data.errors.add :pnr_number, 'Ошибка при создании PNR'
                Sirena::Service.payment_ext_auth(:cancel, response.pnr_number, response.lead_family)
                Sirena::Service.booking_cancel(response.pnr_number, response.lead_family)
              end
            else
              order_data.errors.add :pnr_number,  payment_query.error || 'Ошибка при создании PNR'
              Sirena::Service.booking_cancel(response.pnr_number, response.lead_family)
            end
          end
        else
          order_data.errors.add :pnr_number, response.error || 'Ошибка при создании PNR'
        end
        order_data.pnr_number
      end

      def approve_payment(order)
        error_msg = nil
        payment_confirm = Sirena::Service.payment_ext_auth(:confirm, order.pnr_number, order.sirena_lead_pass,
                                          :cost => (order.price_fare + order.price_tax))
        if payment_confirm.success?
          if payment_confirm.common_status == 'ticket'
            order.ticket!
          else
            error_msg = "Не смогли выписать билет"
            # FIXME: how to cancel ticket in this case?
          end
        else
          error_msg = payment_confirm.error
          Sirena::Service.payment_ext_auth(:cancel, order.pnr_number, order.sirena_lead_pass)
          # we can't simply cancel order if it is in query
          order.cancel!
        end

        error_msg
      end

      def approve_all
        Order.where(
          :source => 'sirena',
          :payment_status => 'blocked',
          :ticket_status => 'booked'
        ).all.each do |order|
          approve_payment order
        end
      end
    end
  end
end
