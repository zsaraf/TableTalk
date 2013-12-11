
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.define("findNearestGameOrMake", function(request, response) {
	var query = new Parse.Query("Game");
	query.near("Location", request.params.location);
	query.limit(2);
	query.find({
		success: function(placesObjects) {
			var found = false;
			if (placesObjects.length > 0) {
				var location = placesObjects[0].get("Location");
				var latitudeDiff = location.latitude - request.params.location.latitude;
				var longitudeDiff = location.longitude - request.params.location.longitude;
				var sqrt = Math.sqrt(latitudeDiff * latitudeDiff + longitudeDiff * longitudeDiff);
				found = sqrt < .5;
			} 
			if (found) {
				response.success(placesObjects[0].get("GameId"));
			} else {
				var Game = Parse.Object.extend("Game");
				var game = new Game();
				game.set("Location", request.params.location);
				game.set("GameId", request.params.location.latitude + "" + request.params.location.longitude);
				game.save(null, {
					success: function(game) {
						response.success(game.get("GameId"));
					},
					error: function(game, error) {
						response.error("Couldn't find game or create game");
					}
				})
			}
		},
		error: function() {
			response.error("error!");
		}
	});	
});
