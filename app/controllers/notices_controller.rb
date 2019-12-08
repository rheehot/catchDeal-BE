class NoticesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :index_json]
  before_action :set_notice, only: [:show, :edit, :update, :destroy]
  include ActionView::Helpers::DateHelper
  load_and_authorize_resource

  # GET /notices
  # GET /notices.json
  def index
    @pagy, @notices = pagy(Notice.order("created_at DESC"), items: 10)
  end
  
  def index_json
    @notices = Notice.order("created_at DESC")
    
    @stackNumber = 1
    @notices.each do |currentData|
      currentData.uid = @stackNumber
      currentData.shortDate = currentData.created_at.strftime('%Y-%m-%d %H:%M:%S')
      currentData.dateAgo = "#{time_ago_in_words(currentData.created_at)} 전"
      @stackNumber += 1
    end
    
    render :json => @notices, :methods => [:uid, :shortDate, :dateAgo], :except => [:id, :user_id, :updated_at]
  end

  # GET /notices/1
  # GET /notices/1.json
  def show
  end

  # GET /notices/new
  def new
    @notice = Notice.new
  end

  # GET /notices/1/edit
  def edit
  end

  # POST /notices
  # POST /notices.json
  def create
    @notice = Notice.new(notice_params)

    respond_to do |format|
      if @notice.save
        format.html { redirect_to @notice, notice: '새 게시글이 생성되었습니다.' }
        format.json { render :show, status: :created, location: @notice }
      else
        format.html { render :new }
        format.json { render json: @notice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notices/1
  # PATCH/PUT /notices/1.json
  def update
    respond_to do |format|
      if @notice.update(notice_params)
        format.html { redirect_to @notice, notice: '게시글이 수정되었습니다.' }
        format.json { render :show, status: :ok, location: @notice }
      else
        format.html { render :edit }
        format.json { render json: @notice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notices/1
  # DELETE /notices/1.json
  def destroy
    @notice.destroy
    respond_to do |format|
      format.html { redirect_to notices_url, notice: '게시글이 삭제되었습니다.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notice
      @notice = Notice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notice_params
      params[:notice][:user_id] = current_user.id
      params.require(:notice).permit(:user_id, :title, :category, :content)
    end
end
