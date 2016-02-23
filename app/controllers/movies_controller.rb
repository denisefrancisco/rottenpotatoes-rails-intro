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
    #session.clear
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
    elsif session[:ratings] == nil then
      @ratings = @all_ratings
    else
      if params[:ratings] != session[:ratings] then
        params[:ratings] = session[:ratings]
        redirect_flag1 = true
      end
      @ratings = params[:ratings].keys
    end
    
    # sort by release or movie title
    @title_header = ""
    @release_header = ""
    if params[:sort] == nil and session[:sort] != nil then
      params[:sort] = session[:sort]
      redirect_flag2 = true
    end
    sort = params[:sort]
    if sort == 'title' then
       @title_header = "hilite"
       @movies = @movies.order("title") #{ |movie| movie.title }
       session[:sort] = sort
    elsif sort == 'release_date' then
       @release_header = "hilite"
       @movies = @movies.order("release_date") #sort_by { |movie| movie.release_date } 
       session[:sort] = sort
    end
    
#=begin
    if session[:sort] != nil and session[:ratings] !=nil then
      if redirect_flag1 == true and redirect_flag2 == true then
        #puts "flag 1 and 2: params = #{params[:sort]}, #{params[:ratings]}, session = #{session[:sort]}, #{session[:ratings]}"
        redirect_to url_for(sort: params[:sort], ratings: params[:ratings]) #and return
      elsif redirect_flag1 == true and params[:sort] == nil then
        #puts "flag 1 only: params = #{params[:sort]}, #{params[:ratings]}, session = #{session[:sort]}, #{session[:ratings]}"
        redirect_to url_for(ratings: params[:ratings]) #and return
      elsif  redirect_flag2 == true and params[:ratings] == nil  then
        #puts "flag 2 only"
        redirect_to url_for(sort: params[:sort]) #and return
      elsif (redirect_flag1 == true or redirect_flag2 == true) then
        redirect_to url_for(sort: params[:sort], ratings: params[:ratings]) #and return
      end
    end
#=end
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
