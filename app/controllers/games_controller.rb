require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
    @start_time = Time.now
  end

  def score
    @result = {}
    @result[:word] = params[:word]
    @result[:time] = Time.now - Time.parse(params[:start_time])
    @result[:score], @result[:message] = compute_score_and_message(params[:word], params[:letters], @result[:time])

    session[:score] ||= 0
    session[:score] += @result[:score].to_i

    @grand_total_score = session[:score]

    respond_to do |format|
      format.html
      format.json { render json: @result }
    end
  end

  private

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def english_word?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    response = URI.open(url).read
    json = JSON.parse(response)
    json['found']
  end

  def compute_score(word, time)
    (word.length.to_f / time.to_f) * 100
  end

  def compute_score_and_message(word, letters, time)
    if included?(word.upcase, letters)
      if english_word?(word)
        score = compute_score(word, time)
        message = "Well done!"
      else
        score = 0
        message = "Not a valid English word"
      end
    else
      score = 0
      message = "Not in the grid"
    end

    [score, "\n#{message}"]
  end
end
