assert = require 'assert'
should = require 'should'

MovieRatingsResource = require '../app/movie-ratings'

describe 'MovieRatingsResource', ->

  movieRatings = {}

  repoSize = -> Object.keys(movieRatings).length

  ratingsEqualRatings = (ratings1, ratings2) ->
    ratings1.length.should.equal ratings2.length
    ratings1.should.containDeep ratings2

  movieRatingsEqualRatings = (movie, ratings) ->
    ratingsEqualRatings movieRatings[movie], ratings

  movieRatingsResource = {}

  beforeEach ->
    movieRatings =
      'Bladerunner': [5, 1]
      'The Empire Strikes Back': [1, 1, 2, 3, 5]
    movieRatingsResource = new MovieRatingsResource movieRatings      

  describe '#getAllMovieRatings()', ->

    it 'should return the correct ratings for all movies', ->
      allMovieRatings = movieRatingsResource.getAllMovieRatings()
      allMovieRatings.should.have.properties movieRatings
      for movie of movieRatings
        movieRatingsEqualRatings movie, allMovieRatings[movie]

  describe '#getMovieRatings()', ->

    it 'should return the correct movie ratings for the requested movie', ->
      movie = 'Bladerunner'
      bladerunnerRatings = movieRatingsResource.getMovieRatings movie
      movieRatingsEqualRatings movie, bladerunnerRatings

    it 'should throw an error if the requested movie does not exist in the repo', ->
      movie = 'Superman'
      assert.throws (-> movieRatingsResource.getMovieRatings movie), /does not exist/

  describe '#putMovieRatings()', ->

    ratings = []
    newRepoSize = 0
    movie = ''

    beforeEach ->
      ratings = [1,2,3,4,5,6,7,8,9]
      newRepoSize = repoSize()

    afterEach ->
      returnedRatings = movieRatingsResource.putMovieRatings movie, ratings
      ratingsEqualRatings returnedRatings, ratings
      movieRatingsEqualRatings movie, ratings
      repoSize().should.equal newRepoSize

    it 'should put a new movie with ratings into the repo and return the ratings', ->
      movie = 'Superman'
      ++newRepoSize;

    it 'should overwrite the ratings of an existing movie in the repo and return the new ratings', ->
      movie = 'Bladerunner'

  describe '#postMovieRating()', ->

    rating = 0
    newRepoSize = 0
    movie = ''
    newRatings = []

    beforeEach ->
      rating = 4
      newRepoSize = repoSize()

    afterEach ->
      returnedRatings = movieRatingsResource.postMovieRating movie, rating
      ratingsEqualRatings returnedRatings, newRatings
      movieRatingsEqualRatings movie, newRatings
      repoSize().should.equal newRepoSize

    it 'should put a new movie with rating into the repo if it does not already exist and return the rating', ->
      newRatings = [rating]
      movie = 'Superman'
      ++newRepoSize;

    it 'should add a new rating to an existing movie in the repo and return the ratings', ->
      movie = 'Bladerunner'
      newRatings = movieRatings[movie].slice()
      newRatings.push rating

  describe '#deleteMovieRatings()', ->

    it 'should delete a movie from the ratings repo', ->
      movie = 'Bladerunner'
      movieRatingsResource.deleteMovieRatings movie
      movieRatings.should.not.have.property(movie)

    it 'should throw an error when attempting to delete a movie that does not exist', ->
      movie = 'Superman'
      assert.throws (-> movieRatingsResource.deleteMovieRatings movie), /does not exist/