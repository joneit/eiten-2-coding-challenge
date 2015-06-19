define ['vendor/jquery'], ($) ->
  module = {}

  module.getAllMovieRatings = (callback) -> $.get '/api/movieratings', callback

  module.getMovieRating = (movie, callback) -> $.get '/api/ratemovie/' + movie, callback

  module.putMovieRatings = (movie, ratings, callback) -> $.ajax {
  	type: 'PUT'
  	url: '/api/movieratings/' + movie,
  	data: { ratings: ratings }
  	success: callback
  }

  module.postMovieRating = (movie, rating, callback) -> $.post '/api/movieratings/' + movie, { rating: rating }, callback

  module.deleteMovieRatings = (movie, callback) -> $.ajax {
  	type: 'DELETE'
  	url: '/api/movieratings/' + movie,
  	success: callback
  }

  return module