class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings
    check_params
    setup_filters
    setup_sorting
    if @sort_field == 'title'
      @movies = Movie.where(rating: @rating_filters).order :title
      @sort_title = 'hilite'
    elsif @sort_field == 'release_date'
      @movies = Movie.where(rating: @rating_filters).order :release_date
      @sort_date = 'hilite'
    else
      @movies = Movie.where(rating: @rating_filters)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private

  def setup_filters
    @rating_filters = params[:ratings].nil? ? [] : params[:ratings].keys
    if @rating_filters.count > 0
      session[:filters] = @rating_filters
    else
      if session[:filters].nil? || session[:filters].count < 1
        session[:filters] = @all_ratings
        @rating_filters = @all_ratings
      else
        @rating_filters = session[:filters]
      end
    end
  end

  def setup_sorting
    @sort_date = ''
    @sort_title = ''
    if params[:sort].nil?
      if session[:sort].nil?
        session[:sort] = ''
        @sort_field = ''
      else
        @sort_field = session[:sort]
      end
    else
      session[:sort] = params[:sort]
      @sort_field = params[:sort]
    end
  end

  def get_params
    temp_ratings = {}
    session[:filters].map {|rating| temp_ratings[rating.to_sym] = '1' }
    ratings = {:ratings => temp_ratings}.to_query
    settings = {
        :utf8 => '✓',
        :commit => 'Refresh',
        :sort => session[:sort]
    }.to_query
    "#{settings}&#{ratings}"
  end

  def check_params
    if params[:ratings].nil? || params[:sort].nil?
      setup_filters
      setup_sorting
      flash.keep
      redirect_to movies_url + '?' + get_params
    end
  end

end
