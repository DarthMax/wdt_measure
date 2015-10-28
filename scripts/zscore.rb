require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)
require 'active_record'
require 'mysql2'


ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql2',
  :database => 'deu_news_2015',
  :username => 'aliss15a',
  :port => 1119,
  :password => "W-aBnP4$f",
  :host     => '127.0.0.1')

class DailyWord < ActiveRecord::Base
    belongs_to :word, foreign_key: :w_id


    BRACET_THRESHOLDS = {
        (0...0.05) => 20,
        (0.05...0.1) => 25,
        (0.1...0.2) => 15,
        (0.2...0.3) => 12,
        (0.3...0.5) => 10,
        (0.5...0.6) => 9,
        (0.6...0.7) => 8,
        (0.7...0.8) => 6,
        (0.8..1) => 5
    }


    def is_trend?
        zscore = ZScore.new(self).value
        bracet_value = 
                DailyWord.
                    where(:w_id => w_id).
                    where("date <= ?",date).
                    count("DISTINCT(date)") / 
                DailyWord.
                    where("date <= ?",date).
                    count("DISTINCT(date)").
                    to_f
        bracet = BRACET_THRESHOLDS.keys.find {|bracet| bracet.include?(bracet_value)}
        zscore >= BRACET_THRESHOLDS[bracet]
    end
end

class Word < ActiveRecord::Base
    has_many :daily_words, foreign_key: :w_id
end


class ZScore
   attr_accessor :word

   def initialize(word)
       @word=word
   end


   def value
       ((word.freq / words_in_range.to_f) - mean) / standard_derivation.to_f
   end

   private

   def words_in_range
        @words_in_range ||= DailyWord.where("date = ?",@word.date).count("DISTINCT(w_id)")
   end

   def daily_count
        @daily_count||= DailyWord.where(:w_id => word.w_id).where("date <= ?", @word.date).pluck(:freq).map {|v| v/words_in_range.to_f}
   end

   def mean
       @mean ||= daily_count.inject(&:+) / daily_count.count.to_f
   end

   def standard_derivation
       @standard_derivation ||= Math.sqrt(daily_count.map{|value| (value-mean)**2 }.inject(&:+) / daily_count.count.to_f)
   end

end
