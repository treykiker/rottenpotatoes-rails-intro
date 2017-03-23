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
    @all_ratings = Movie.all_ratings
    redirect = false
    
    logger.debug(session.inspect)
    
    if params[:sort_by]
      @sort_column = params[:sort_by]
      session[:sort_by] = params[:sort_by]
    elsif session[:sort_by]
      @sort_column = session[:sort_by]
      redirect = true
    else
      @sort_column = nil
    end
    
    if params[:commit] == "Refresh" && params[:ratings].nil?
      @set_ratings = nil
      session[:ratings] = nil
    elsif params[:ratings]
      @set_ratings = params[:ratings]
      session[:ratings] = params[:ratings]
    elsif session[:ratings]
      @set_ratings = session[:ratings]
      redirect = true
    else
      @set_ratings = nil
    end
    
    if redirect
      flash.keep
      redirect_to movies_path :sort_by=>@sort_column, :ratings=>@set_ratings
    end
    
    if @set_ratings && @sort_column
      @movies = Movie.where(:rating => @set_ratings.keys).order(@sort_column)
    elsif @set_ratings
      @movies = Movie.where(:rating => @set_ratings.keys)
    elsif @sort_column
      @movies = Movie.order(@sort_column)
    else
      @movie = Movie.all
    end
      
    if !@set_ratings
      @set_ratings = Hash.new
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

end
