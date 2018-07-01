#!/usr/bin/env ruby
require "nokogiri"
require "open-uri"
require "date"
require "time"
require "net/http"
require "http"
require "json"
require 'faye/websocket'
require 'eventmachine'


class BotBrain



  def self.bot_answer
    answer = "🇫🇷 *ALLEZ LES BLEUS* 🇫🇷\r\r"
    (0..3).each do |i|
      retrieve_score_a[i] = 0 if retrieve_score_a[i] == ""
      retrieve_score_b[i] = 0 if retrieve_score_b[i] == ""

      if retrieve_countries_a == "France" || retrieve_countries_b == "France"
        answer << "🇫🇷 *Cocorico!!* 🇫🇷\r Tous avec les bleus ajourd'hui"
      end

      if retrieve_status[i] == "Fin"
        if Time.parse(retrieve_dates[i]).to_date == Date.today
          answer << "• Score final: *#{retrieve_countries_a[i]}* [#{retrieve_score_a[i]} - #{retrieve_score_b[i]}] *#{retrieve_countries_b[i]}* \r"
        end
      elsif Time.parse(retrieve_start_times[i]) > (Time.now + 7200)
        answer << "• Le #{retrieve_dates[i]}, à *#{retrieve_start_times[i]}* les équipes du #{retrieve_groups[i]} *#{retrieve_countries_a[i]}* et *#{retrieve_countries_b[i]}* s'affrontent à #{retrieve_venues[i]}. _Le match n'a pas encore commencé_ 😕 \r\r"
      elsif retrieve_live_match.to_s.include?(retrieve_dates[i])
        answer << "• Pour l'instant le score est de *#{retrieve_score_a[i]}* pour *#{retrieve_countries_a[i]}* et *#{retrieve_score_b[i]}* pour *#{retrieve_countries_b[i]}* \r"
      end
    end
    answer
  end

  private

    def self.doc
      Nokogiri::HTML(open("https://fr.fifa.com/worldcup"))
    end

    def self.retrieve_dates
      doc.css('.fi-mu__info').map {|date| date.css('.fi__info__datetime--abbr').map(&:text)}.flatten.map {|date| date.gsub( / *\n+/, "" ).gsub( / *\r+/, "" ).lstrip.rstrip }
    end

    def self.retrieve_start_times
      doc.css('.fi-mu__m').map {|time| time.css('.fi-mu__score-info').css('.fi-mu__match-time').css('.fi-s__scoreText').map(&:text)}.flatten.map{|time| time.gsub( / *\n+/, "" ).gsub( / *\r+/, "" ).lstrip.rstrip }.map {|time| (Time.parse(time) - 3600).strftime("%H:%M")}
    end

    def self.retrieve_groups
      doc.css('.fi-mu__info').map {|group| group.css('.fi__info__group').map(&:text)}.flatten
    end

    def self.retrieve_venues
      doc.css('.fi-mu__info').map {|venue| venue.css('.fi__info__location').css('.fi__info__venue').map(&:text)}.flatten
    end

    def self.retrieve_countries_a
      doc.css('.fi-mu__m').map {|country_a| country_a.css('.home').css('.fi-t__n').css('.fi-t__nText').map(&:text)}.flatten
    end

    def self.retrieve_countries_b
      doc.css('.fi-mu__m').map {|country_b| country_b.css('.away').css('.fi-t__n').css('.fi-t__nText').map(&:text)}.flatten
    end

    def self.retrieve_score_a
      score =doc.css('.fi-mu__m').map {|score_a| score_a.css('.fi-mu__score-info').css('.fi-mu__score-wrap').css('.home').map(&:text)}.flatten
    end

    def self.retrieve_score_b
      doc.css('.fi-mu__m').map {|score_b| score_b.css('.fi-mu__score-info').css('.fi-mu__score-wrap').css('.away').map(&:text)}.flatten
    end

    def self.retrieve_status
      match_status = doc.css('.fi-mu__m').map {|status| status.css('.fi-mu__score-info').css('.fi-s__status').css('.period:not(.hidden)').map(&:text)}.flatten.map {|st| st.gsub( / *\n+/, "" ).gsub( / *\r+/, "" ).rstrip}
    end

    def self.retrieve_live_match
      match_status = doc.css('.fi-mu__item').map {|status| status.css('.fi-mu__link').css('.live').map(&:text)}.flatten.map {|st| st.gsub( / *\n+/, "" ).gsub( / *\r+/, "" ).rstrip}
    end

end

