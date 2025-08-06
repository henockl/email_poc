class NewslettersController < ApplicationController
  before_action :set_newsletter, only: [ :show, :edit, :update, :destroy ]

  def index
    @newsletters = Newsletter.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @newsletter = Newsletter.new
    @newsletter.publish_date = next_sunday
  end

  def create
    @newsletter = Newsletter.new(newsletter_params)

    if @newsletter.save
      Bento::Emails.send(
        to: "henockl@live.com",
        from: "noreply@pzncheck.com",
        subject: "New Newsletter Created",
        html_body: "<p>A new newsletter has been created.</p>"
      )
      redirect_to @newsletter, notice: "Newsletter was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    unless @newsletter.can_edit?
      redirect_to @newsletter, alert: "Cannot edit a published newsletter."
      nil
    end
  end

  def update
    unless @newsletter.can_edit?
      redirect_to @newsletter, alert: "Cannot edit a published newsletter."
      return
    end

    if @newsletter.update(newsletter_params)
      redirect_to @newsletter, notice: "Newsletter was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @newsletter.published?
      redirect_to newsletters_path, alert: "Cannot delete a published newsletter."
    else
      @newsletter.destroy
      redirect_to newsletters_path, notice: "Newsletter was successfully deleted."
    end
  end

  private

  def set_newsletter
    @newsletter = Newsletter.find(params[:id])
  end

  def newsletter_params
    params.require(:newsletter).permit(:title, :content, :published, :publish_date)
  end


  def next_sunday
    today = Date.current
    days_until_sunday = (7 - today.wday) % 7
    days_until_sunday = 7 if days_until_sunday == 0 # If today is Sunday, get next Sunday
    today + days_until_sunday.days
  end
end
