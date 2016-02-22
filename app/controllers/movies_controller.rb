class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
    session[:sort] = ''
    session[:ratings] = params[:rating]
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
    @all_ratings = Movie.all_ratings
    redirect_flag1 = false
    redirect_flag2 = false
    #want to store in session hash: ratings and sort
    
    # filter by ratings
    if params[:ratings] != nil then
      @ratings = params[:ratings].keys
      session[:ratings] = params[:ratings]
      @movies = Movie.where(rating: @ratings)
      #flash[:notice] = "#{@ratings} was successfully created."
    elsif session[:ratings] == nil then
      @ratings = @all_ratings
      flash[:notice] = "#{session[:ratings]} set for sessions ratings"
    else
      params[:ratings] = session[:ratings]
      redirect_flag1 = true
      flash[:notice] = "#{params[:ratings]} set for params ratings"
      @ratings = params[:ratings].keys
      #flash[:notice] = "#{@ratings} is default."
      #session[:current_user_id] = @user.id
      #flash[:notice] = "#{@user.id} is the user."
    end
    
    # sort by release or movie title
    @title_header = ""
    @release_header = ""
    if params[:sort] == nil and session[:sort] != '' then
      params[:sort] = session[:sort]
      redirect_flag2 = true
    end
    sort = params[:sort]
    if sort == 'title' then
       @title_header = "hilite"
       @movies = @movies.sort_by { |movie| movie.title }
    elsif sort == 'release_date' then
       @release_header = "hilite"
       @movies = @movies.sort_by { |movie| movie.release_date } 
    end
    if sort !=nil then
      session[:sort] = sort
    end
    
    if session[:sort] != '' and session[:ratings] !=nil then
      if redirect_flag1 == true and redirect_flag2 == true then
        flash[:notice] = "flag 1 and 2: params = #{params[:sort]}, #{params[:ratings]}, session = #{session[:sort]}, #{session[:ratings]}"
        redirect_to url_for(sort: params[:sort], ratings: params[:ratings]) #and return
      elsif redirect_flag1 == true and params[:sort] == nil then
        flash[:notice] = "flag 1 only: params = #{params[:sort]}, #{params[:ratings]}, session = #{session[:sort]}, #{session[:ratings]}"
        redirect_to url_for(ratings: params[:ratings]) #and return
      elsif redirect_flag2 == true and params[:ratings] == nil  then
        flash[:notice] = "flag 2 only"
        redirect_to url_for(sort: params[:sort]) #and return
      elsif (redirect_flag1 == true or redirect_flag2 == true) and (params[:sort] != nil and params[:rating] != nil) then
        flash[:notice] = "flag 1 and 2: params = #{params[:sort]}, #{params[:ratings]}, session = #{session[:sort]}, #{session[:ratings]}"
        redirect_to url_for(sort: params[:sort], ratings: params[:ratings]) #and return
      end
    end
    #session.clear
    
    #flash[:notice] = "#{session[:ratings]} are the ratings--- and #{session[:sort]} is the sorting. --- and #{params[:ratings]} are the ratings params."
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
