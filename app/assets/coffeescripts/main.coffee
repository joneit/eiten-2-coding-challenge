requirejs.config
  baseUrl: '/javascripts'
  paths:
    vendor: './vendor'
  shim:
    'vendor/jquery':
      exports: 'jQuery'
    'vendor/underscore':
      exports: '_'
    'vendor/handlebars':
      exports: 'Handlebars'

dependencies = [
  'vendor/jquery'
  'vendor/underscore'
  'vendor/handlebars'
  'movie-ratings-service-client'
]

requirejs dependencies, ($, _, Handlebars, ratingsService) ->

  ratedMovieTemplate = """
                       <div class="rated-movie" id="{{movieName}}">
                         <div class="movie-title">
                           {{movieName}}
                           <div class="del" title="Delete this movie and all its ratings.">x</div>
                         </div>
                         <div class="stars">
                           <div><span>{{totalRatings}} ratings</span></div>
                           <div style="width:{{rating}}em">&#x2605;&#x2605;&#x2605;&#x2605;&#x2605;</div>
                           <div></div>
                         </div>
                         <div class="movie-rating">{{rating}} out of 5 stars</div>
                         <table>
                           <tr><td>5-star</td><td><div style="width:{{star5}}px">&nbsp;</div></td><td>{{star5}}</td></tr>
                           <tr><td>4-star</td><td><div style="width:{{star4}}px">&nbsp;</div></td><td>{{star4}}</td></tr>
                           <tr><td>3-star</td><td><div style="width:{{star3}}px">&nbsp;</div></td><td>{{star3}}</td></tr>
                           <tr><td>2-star</td><td><div style="width:{{star2}}px">&nbsp;</div></td><td>{{star2}}</td></tr>
                           <tr><td>1-star</td><td><div style="width:{{star1}}px">&nbsp;</div></td><td>{{star1}}</td></tr>
                          </table>
                          <div class="rate-this-movie">
                            Rate this movie:
                            <span>&#x2606;</span><span>&#x2606;</span><span>&#x2606;</span><span>&#x2606;</span><span>&#x2606;</span>
                            <input type="button" class="reset-ratings" value="Reset Ratings" title="Reset ratings to [1,2,3,4,5]">
                          </div>
                       </div>
                       """

  ratedMovieSection = Handlebars.compile ratedMovieTemplate

  buildMovieRatingsSection = (thisMovieRatings, movie, rating) ->
    rating = rating.toFixed(1) if rating|0 isnt rating

    counts = _(thisMovieRatings).countBy()
    counts[i] = counts[i] ? 0 for i in [1..5]
    pct = _(counts).map((num) -> Math.round(num / thisMovieRatings.length * 100))

    $html = $ ratedMovieSection {
      movieName: movie,
      rating: rating,
      totalRatings: thisMovieRatings.length,
      star1: pct[0],
      star2: pct[1],
      star3: pct[2],
      star4: pct[3],
      star5: pct[4]
    }

    $html.find('.del').click ->
      if confirm 'Are you sure you want to delete this movie?\n\n\t"' + movie + '"'
        ratingsService.deleteMovieRatings movie, ->
          $html.remove()

    $html.find('.reset-ratings').click ->
      newRatings = [1,2,3,4,5]
      ratingsService.putMovieRatings movie, newRatings, ->
        ratingsService.getMovieRating movie, (rating) ->
          $('div[id="' + movie + '"').replaceWith buildMovieRatingsSection newRatings, movie, rating
        
    $stars = $html.find('.rate-this-movie > span')

    $stars.mouseenter ->
      theStar = this
      found = false
      _($stars).each (thisStar) ->
        thisStar.innerHTML = if found then '&#x2606;' else '&#x2605;'
        found = true if thisStar is theStar 

    $stars.click ->
      theStar = this
      $stars.each (index, thisStar) ->
        if thisStar is theStar 
          ratingsService.postMovieRating movie, index + 1, (thisMovieRatings) ->
            ratingsService.getMovieRating movie, (rating) ->
              $('div[id="' + movie + '"').replaceWith buildMovieRatingsSection thisMovieRatings, movie, rating
          return false # early exit

    return $html

  ratingsService.getAllMovieRatings (ratings) ->
    for movie of ratings
      do (movie) ->
        ratingsService.getMovieRating movie, (rating) ->
          $('body').append buildMovieRatingsSection ratings[movie], movie, rating


  