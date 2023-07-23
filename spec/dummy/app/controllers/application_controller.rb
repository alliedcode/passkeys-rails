class ApplicationController < ActionController::Base
  before_action :authenticate_passkey!, only: :index

  def index
    render json: { username: current_agent&.username }
  end

  def home
    render json: { username: current_agent&.username }
  end
end
