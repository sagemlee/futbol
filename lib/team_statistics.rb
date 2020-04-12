class TeamStatistics

  attr_reader :game_collection, :game_teams_collection, :teams_collection
  def initialize(game_collection, game_teams_collection, teams_collection)
    @game_collection = game_collection
    @game_teams_collection = game_teams_collection
    @teams_collection = teams_collection
  end

  def team_info(team_id)
    # A hash with key/value pairs for the following attributes: team_id, franchise_id, team_name, abbreviation, and link

    team = @teams_collection.find{ |team| team.id == team_id}
    team_info = {"team_id" => team.id,
                 "franchise_id" => team.franchise_id,
                 "team_name" => team.team_name,
                 "abbreviation" => team.abbreviation,
                 "link" => team.link}
  end

  def games_played(team_id)
    # This method can probably be combined in a module with games_played_by_team in league statistics
    @game_collection.find_all do |game|
      game.away_team_id == team_id || game.home_team_id == team_id
    end
  end

  def best_season(team_id)
    # Season with the highest win percentage for a team.
    # Find all home and away games for team_id
    # Group by season
    # Compare wins vs total games for each season
    # Find max win percentage
    games_played_in = games_played(team_id)
    games_by_season = games_played_in.group_by {|game| game.season}
    win_percentage_by_season = games_by_season.transform_values do |season|
      games_won = 0

      season.each do |game|
        if team_id == game.away_team_id && game.away_goals > game.home_goals
          games_won += 1
        elsif team_id == game.home_team_id && game.home_goals > game.away_goals
          games_won += 1
        end
      end
      (games_won/season.length.to_f).round(2)
    end
    best_season = win_percentage_by_season.max_by { |season| season[1]}
    best_season[0]
  end

  def worst_season(team_id)
    # Season with the lowest win percentage for a team.
    # Find all home and away games for team_id
    # Group by season
    # Compare wins vs total games for each season
    # Find min win percentage

    games_played_in = games_played(team_id)
    games_by_season = games_played_in.group_by {|game| game.season}
    win_percentage_by_season = games_by_season.transform_values do |season|
      games_won = 0

      season.each do |game|
        if team_id == game.away_team_id && game.away_goals > game.home_goals
          games_won += 1
        elsif team_id == game.home_team_id && game.home_goals > game.away_goals
          games_won += 1
        end
      end
      (games_won/season.length.to_f).round(2)
    end
    worst_season = win_percentage_by_season.min_by { |season| season[1]}
    worst_season[0]
  end

  def average_win_percentage(team_id)
    # Average win percentage of all games for a team
    # Find all home and away games for team_id
    # compare wins vs total games
    # Report win percentage
    games_played_in = games_played(team_id)
    games_won = 0
    games_played_in.each do |game|
      if team_id == game.away_team_id && game.away_goals > game.home_goals
        games_won += 1
      elsif team_id == game.home_team_id && game.home_goals > game.away_goals
        games_won += 1
      end
    end
    (games_won.to_f/games_played_in.length).round(2)

  end

  def most_goals_scored(team_id)
    # Highest number of goals the team scored in a single game
    # Find all home and away games for team_id
    # Iterate through games and find game with highest goals scored
    games_played_in = games_played(team_id)
    home_games = games_played_in.find_all{|game| game.home_team_id == team_id}
    away_games = games_played_in.find_all{|game| game.away_team_id == team_id}

    highest_scoring_home_game = home_games.max_by{|game| game.home_goals}
    highest_scoring_away_game = away_games.max_by{|game| game.away_goals}

    if highest_scoring_home_game.home_goals >= highest_scoring_away_game.away_goals
        highest_scoring_home_game.home_goals
    else
        highest_scoring_away_game.away_goals
    end

  end

  def fewest_goals_scored(team_id)

    # Lowest number of goals a team scored in a single game
    #  Find all home and away games for team_id
    # Iterate through games and find game with lowest scored goals
    games_played_in = games_played(team_id)
    home_games = games_played_in.find_all{|game| game.home_team_id == team_id}
    away_games = games_played_in.find_all{|game| game.away_team_id == team_id}

    lowest_scoring_home_game = home_games.min_by{|game| game.home_goals}
    lowest_scoring_away_game = away_games.min_by{|game| game.away_goals}

    if lowest_scoring_home_game.home_goals <= lowest_scoring_away_game.away_goals
        lowest_scoring_home_game.home_goals
    else
        lowest_scoring_away_game.away_goals
    end
  end

  def favorite_opponent(team_id)
    # Name of the opponent that has the lowest win percentage against the given team
    games_played_in = games_played(team_id)

    games_by_opponent_id = Hash.new { |h, k| h[k] = [] }
    games_played_in.each do |game|
      games_by_opponent_id[game.away_team_id] << game
      games_by_opponent_id[game.home_team_id] << game
    end
    games_by_opponent_id.delete(team_id)

    win_percentage_by_opponent = games_by_opponent_id.transform_values do |games_played_against_opponent|
      games_won = 0
      games_played_against_opponent.each do |game|
        if team_id == game.away_team_id && game.away_goals > game.home_goals
          games_won += 1
        elsif team_id == game.home_team_id && game.home_goals > game.away_goals
          games_won += 1
        end
      end
      (games_won/games_played_against_opponent.length.to_f).round(2)
    end
    # fav_opponent [0] -> team_id, [1] -> win percentage
    fav_opponent = win_percentage_by_opponent.max_by {|opponent| opponent[1]}
    team_info(fav_opponent[0])["team_name"]
  end

  def rival(team_id)
    # Name of the opponent that has the highest win percentage against the given team

    games_played_in = games_played(team_id)

    games_by_opponent_id = Hash.new { |h, k| h[k] = [] }
    games_played_in.each do |game|
      games_by_opponent_id[game.away_team_id] << game
      games_by_opponent_id[game.home_team_id] << game
    end
    games_by_opponent_id.delete(team_id)

    win_percentage_by_opponent = games_by_opponent_id.transform_values do |games_played_against_opponent|
      games_won = 0
      games_played_against_opponent.each do |game|
        if team_id == game.away_team_id && game.away_goals > game.home_goals
          games_won += 1
        elsif team_id == game.home_team_id && game.home_goals > game.away_goals
          games_won += 1
        end
      end
      (games_won/games_played_against_opponent.length.to_f).round(2)
    end
    # fav_opponent [0] -> team_id, [1] -> win percentage
    fav_opponent = win_percentage_by_opponent.min_by {|opponent| opponent[1]}
    team_info(fav_opponent[0])["team_name"]
  end
end