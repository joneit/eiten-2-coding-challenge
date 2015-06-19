module.exports = (ratings) ->

	insufficient = 'Not enough ratings'
	
	throw new Error 'Invalid arguments' unless ratings instanceof Array and arguments.length == 1
	
	throw new Error insufficient if ratings.length < 3

	min = Number.POSITIVE_INFINITY
	max = Number.NEGATIVE_INFINITY

	len = ratings.length
	sum = 0

	# single-pass, memory-neutral algorithm for unordered ratings[]
	for i in [0..len - 1]
		rating = parseInt ratings[i]

		sum += rating

		if rating < min
			min = rating
			minRatings = 1
		else if rating == min
			minRatings += 1
		
		if rating > max
			max = rating
			maxRatings = 1
		else if rating == max
			maxRatings += 1

	throw new Error insufficient + ': nothing to trim' if minRatings == len
	throw new Error insufficient + ': nothing left after trimming' if minRatings + maxRatings == len

	sum -= min * minRatings + max * maxRatings
	len -= minRatings + maxRatings
	avg = sum / len