class SubscribersController < ApplicationController
  before_action :set_subscriber, only: [ :show, :edit, :update, :destroy ]

  def index
    @subscribers = Subscriber.all.order(:name)
    @active_count = @subscribers.active.count
    @inactive_count = @subscribers.inactive.count
  end

  def show
  end

  def new
    @subscriber = Subscriber.new
  end

  def create
    @subscriber = Subscriber.new(subscriber_params)

    if @subscriber.save
      redirect_to @subscriber, notice: "Subscriber was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @subscriber.update(subscriber_params)
      redirect_to @subscriber, notice: "Subscriber was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @subscriber.destroy
    redirect_to subscribers_path, notice: "Subscriber was successfully deleted."
  end

  private

  def set_subscriber
    @subscriber = Subscriber.find(params[:id])
  end

  def subscriber_params
    params.require(:subscriber).permit(:name, :email, :active)
  end
end
