class ArticlesController < ApplicationController
  before_action :set_article, only: %i[ show edit update destroy versions version revert]
  before_action :set_version, only: [:version, :revert]


  # GET /articles or /articles.json
  def index
    @articles = Article.all
  end

  # GET /articles/1 or /articles/1.json
  def show
  end



  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  def version
  end

  # POST /articles or /articles.json
  def create
    @article = Article.new(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to article_url(@article), notice: "Article was successfully created." }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1 or /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to article_url(@article), notice: "Article was successfully updated." }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
    @article.destroy

    respond_to do |format|
      format.html { redirect_to articles_url, notice: "Article was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def versions
    @articles = @article.versions
  end

  def revert
    @reverted_article = @version.reify
    if @reverted_article.save
      redirect_to @article, notice: "Article was successfully reverted."
    else
      render version
    end
  end

  def deleted
    @destroyed_versions = PaperTrail::Version.where(item_type: "Article", event: "destroy").order(created_at: :desc)
    @latest_destroyed_versions = @destroyed_versions.filter { |v| v.reify.versions.last.event == "destroy" }.map(&:reify).uniq(&:id)
    @articles = @latest_destroyed_versions
  end

    def restore
    @latest_version = Article.new(id: params[:id]).versions.last
    if @latest_version.event == "destroy"
      @article = @latest_version.reify
      if @article.save
        redirect_to @article, notice: "Article was successfully restored."
      else
        render "deleted"
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    def set_version
      @version = PaperTrail::Version.find_by(item_id: @article, id: params[:version_id])
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.require(:article).permit(:title, :body)
    end


  end
