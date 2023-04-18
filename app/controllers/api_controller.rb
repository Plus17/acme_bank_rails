class ApiController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :require_json

  private

  def require_json
    if !request.format.json?
      head 406
    end
  end
end
