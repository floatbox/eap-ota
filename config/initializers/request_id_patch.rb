# оверрайд для actionpack/lib/action_dispatch/middleware/request_id.rb
# request_id слишком длинный.
module ActionDispatch
  class RequestId
  private
    def internal_request_id
      SecureRandom.hex(6)
    end
  end
end
