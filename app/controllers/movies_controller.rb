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
    #session[:sort] = ''
    #session[:ratings] = params[:ratings]
    @movies = Movie.all
    @all_ratings = Movie.all_ratings
    #want to store in session hash: ratings and sort
    
    # filter by ratings
    if params[:ratings] != nil then
      @ratings = params[:ratings].keys
      session[:ratings] = params[:ratings]
      @movies = Movie.where(rating: @ratings)
      #flash[:notice] = "#{@ratings} was successfully created."
    elsif session[:rating] == nil then
      @ratings = @all_ratings
    else
      params[:ratings] = session[:ratings]
      @ratings = params[:ratings].keys
      #flash[:notice] = "#{@ratings} is default."
      #session[:current_user_id] = @user.id
      #flash[:notice] = "#{@user.id} is the user."
    end
    
    # sort by release or movie title
    @title_header = ""
    @release_header = ""
    if params[:sort] == nil then
      params[:sort] = session[:sort]
    end
    sort = params[:sort]
    if sort == 'title' then
       @title_header = "hilite"
       @movies = @movies.sort_by { |movie| movie.title }
    elsif sort == 'release_date' then
       @release_header = "hilite"
       @movies = @movies.sort_by { |movie| movie.release_date } 
    end
    session[:sort] = sort
    flash[:notice] = "#{session[:ratings]} are the ratings and #{session[:sort]} is the sorting."
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

end
