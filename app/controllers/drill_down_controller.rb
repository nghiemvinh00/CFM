#
# Giang NGUYEN
# ndgiang84@gmail.com
# Hanoi, Feb-2011
#

class DrillDownController < ApplicationController
  def index
    case params[:drilldown]
      when 'movie'
        logger.info "Movie drilldown"
        movie_id, city_id, place_id = params[:movie_id], params[:movie_city_id], params[:movie_place_id]
        if place_id.blank?
          places = Place.get_places_for_movie_in_city(movie_id, city_id)
          @map = Place.get_places_map(places)
          @map_title = "Places for movie <b>#{Movie.find_by_id(movie_id).name}</b> in city <b>#{City.find_by_id(city_id).name}</b>:"
        else 
          place = Place.find_by_id(params[:movie_place_id])
          @map = place.get_place_map
          @map_title = "<b>Other Movies Filmed Here:</b> " << (place.movies.map(&:name).reject { |m| m == Movie.find_by_id(params[:movie_id]).name }).join(',')
        end
      when 'city'
        logger.info "City drilldown"
        city_id, place_id, movie_id = params[:city_id], params[:city_place_id], params[:city_movie_id]
        if place_id.blank?
          places = City.find_by_id(city_id).places
          @map = Place.get_places_map(places)
          @map_title = "Places in city <b>#{City.find_by_id(city_id).name}</b>"
        else
          place = Place.find_by_id(place_id)
          @map = place.get_place_map
          @map_title = "Movies Filmed Here: " << place.movies.map(&:name).join(',')
        end
      when 'place'
        logger.info "Place drilldown"
        place_id, city_id, movie_id = params[:place_id], params[:place_city_id], params[:place_movie_id]
        if city_id.blank?
          place = Place.find_by_id(place_id)
          @map = place.get_place_map
          @map_title = ""
        else 
          if movie_id.blank?
            places = City.find_by_id(city_id).places
            @map = Place.get_places_map(places)
            @map_title = "Places in city <b>#{City.find_by_id(city_id).name}</b>"
          else
            places = Place.get_places_for_movie_in_city(movie_id, city_id)
            @map = Place.get_places_map(places)
            @map_title = "Places for movie <b>#{Movie.find_by_id(movie_id).name}</b> in city <b>#{City.find_by_id(city_id).name}</b>:"
          end
        end
      else
        logger.info "just load the drilldown index"
    end
  end

  ### movie drill drown
  def movie_filming_movie
    movie_id = params[:movie_id]
    city_id = params[:movie_city_id]
    place_id = params[:movie_place_id]

    if movie_id.blank? || city_id.blank? || place_id.blank? 
      redirect_to drill_down_index_path, :notice => 'Must choose movie, city and place.'
      return
    end

    Movie.film_in_place(movie_id, place_id)
    redirect_to drill_down_index_path, :notice => "#{Movie.find_by_id(movie_id).name} was filmed in #{Place.find_by_id(place_id).name}, #{City.find_by_id(city_id).name}"
  end

  def movie_associated_cities
    associated_cities = Movie.find_associated_cities(params[:id])
    cities_select_content = render_to_string :partial => "cities_select_content", :locals => { :city_options => associated_cities }
    render :text => cities_select_content
  end

  def movie_associated_places
    associated_places = City.find_associated_places(params[:id])
    places_select_content = render_to_string :partial => "places_select_content", :locals => { :place_options => associated_places }
    render :text => places_select_content
  end

  ### citi drill down
  def city_filming_movie
    city_id = params[:city_id]
    place_id = params[:city_place_id]
    movie_id = params[:city_movie_id]

    if movie_id.blank? || city_id.blank? || place_id.blank? 
      redirect_to drill_down_index_path, :notice => 'Must choose movie, city and place.'
      return
    end

    City.film_in_place(movie_id, place_id, city_id)
    redirect_to drill_down_index_path, :notice => "#{Movie.find_by_id(movie_id).name} was already filmed in #{Place.find_by_id(place_id).name}, #{City.find_by_id(city_id).name}"
  end

  def city_associated_places
    associated_places = City.find_associated_places(params[:id])
    places_select_content = render_to_string :partial => "places_select_content", :locals => { :place_options => associated_places }
    render :text => places_select_content
  end

  def city_associated_movies
    associated_movies = Place.find_associated_movies(params[:id])
    movies_select_content = render_to_string :partial => "movies_select_content", :locals => { :movie_options => associated_movies }
    render :text => movies_select_content
  end

  ### place drill down
  def place_filming_movie
    place_id = params[:place_id]
    city_id = params[:place_city_id]
    movie_id = params[:place_movie_id]

    if movie_id.blank? || city_id.blank? || place_id.blank? 
      redirect_to drill_down_index_path, :notice => 'Must choose movie, city and place.'
      return
    end

    Place.film_in_place(movie_id, place_id)
    redirect_to drill_down_index_path, :notice => "#{Movie.find_by_id(movie_id).name} was filmed in #{Place.find_by_id(place_id).name}, #{City.find_by_id(city_id).name}"
  end

  def place_associated_cities
    associated_cities = Place.find_associated_cities(params[:id])
    cities_select_content = render_to_string :partial => "cities_select_content", :locals => { :city_options => associated_cities }
    render :text => cities_select_content
  end

  def place_associated_movies
    associated_movies = City.find_associated_movies(params[:id])
    movies_select_content = render_to_string :partial => "movies_select_content", :locals => { :movie_options => associated_movies }
    render :text => movies_select_content
  end
end
