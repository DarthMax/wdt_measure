
-- Need 



   
SELECT @total_frequence_day := (
   SELECT       SUM(freq) 
   FROM         daily_words 
   WHERE        date = Date("2015-01-01")
   ) total_freq_day;
             
SELECT @total_frequence_2014 := (
    SELECT       SUM(freq) 
    FROM         deu_news_2014.words 
    WHERE        w_id >  30
    ) AS total_freq_2014;

SELECT      words2015.word,
            words2015.w_id,
            day.freq, 
            day.freq * (log(day.freq)-log(daily_freq_sums.freq_sum * (year.freq+day.freq)/@total_frequence_2014)-1) / log(daily_freq_sums.freq_sum) AS new_poisson,
            day.freqratio,
            day.poisson,
            day.date
FROM        daily_words day
            LEFT OUTER JOIN  words words2015 
            ON               words2015.w_id=day.w_id 
            LEFT OUTER JOIN   deu_news_2014.words year 
            ON                words2015.word = year.word 
            JOIN  ( SELECT       date, SUM(freq) freq_sum
                    FROM         daily_words 
                    WHERE w_id > 30
                    GROUP BY date) daily_freq_sums 
            ON daily_freq_sums.date = day.date  
ORDER BY    new_poisson 
DESC 
LIMIT 100 ; 

-- total frequencies on one date
   SELECT       date, SUM(freq) 
   FROM         daily_words 
   WHERE w_id > 30
   GROUP BY date
   ORDER BY date

-- versuch
SELECT words.word, words.w_id, date 
        FROM daily_words 
        JOIN words
        ON words.w_id = daily_words.w_id
        GROUP BY date 
        LIMIT 20;

 INSERT INTO aliss15a_daily_words (w_id, date, poisson) (
    SELECT 
            now.w_id,
            now.date, 
            ((now.relative_freq - ref_aliss.mean) / ref_aliss.standard_derivation)
        
        FROM aliss15a_daily_words as now
        JOIN words as now_words on now_words.w_id = now.w_id
        JOIN deu_news_2014.words as ref on now_words.word = ref.word
        JOIN deu_news_2014.aliss15a_words as ref_aliss on ref.w_id = ref_aliss.w_id
) ON DUPLICATE KEY UPDATE z_score=values(z_score);

