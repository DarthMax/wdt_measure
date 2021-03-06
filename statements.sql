-- in deu_news_2014
-- Tabelle für vorberechnete Werte
-- =================================
CREATE TABLE aliss15a_words (
    w_id INT(10) UNSIGNED PRIMARY KEY,
    relative_document_frequency FLOAT, -- Anzahl der Tage an denen wort Vorkommt / 365ish
    mean FLOAT,
    standard_derivation FLOAT,
    FOREIGN KEY (w_id)  
        REFERENCES words(w_id),
);


-- Tabelle für vorberechnete relative Häufigkeiten, etc..
-- ========================================================
CREATE TABLE aliss15a_daily_words (
    w_id INT(10) UNSIGNED,
    date date,
    relative_freq FLOAT,
    z_score FLOAT,
    tf_idf FLOAT,
    poisson FLOAT,
    freqratio FLOAT,
    PRIMARY KEY(w_id, date),
    FOREIGN KEY (w_id)  
        REFERENCES daily_words(w_id),
    INDEX (date)
);



-- Berechne Relative Wortfrequenz pro Wort und Tag
-- Als Referenz dient die Frequenz des Wortes "der" am jeweiligen Tag
-- Berechnung für jeden Tag im referenz- und im aktuellen Corpus
-- ===================================================================
select @der_id:=(select w_id from words where word='der');

INSERT INTO aliss15a_daily_words (w_id,date,relative_freq) (
    SELECT w_id, daily_words.date, (daily_words.freq/daily_der.freq) 
        FROM daily_words 
            JOIN (SELECT date, freq FROM daily_words WHERE w_id=@der_id) AS daily_der ON daily_der.date=daily_words.date   
) ON DUPLICATE KEY UPDATE relative_freq=values(relative_freq);


-- Berechne Erwartungswert und Standardabweichung pro Wort
-- =========================================================
INSERT INTO aliss15a_words (w_id,mean,standard_derivation) (
    SELECT w_id, AVG(relative_freq), STD(relative_freq) 
        FROM aliss15a_daily_words 
        GROUP BY w_id
) ON DUPLICATE KEY UPDATE mean=values(mean), standard_derivation=values(standard_derivation);


-- Berechne Dokumentenhäufigkeit pro Wort (Dokument = 1 Tag)
-- ==========================================================
INSERT INTO aliss15a_words (w_id,relative_document_frequency) ( 
    SELECT daily_words.w_id, (word_counts.wc/(SELECT COUNT(DISTINCT date) from daily_words)) 
        FROM daily_words
        JOIN (
            SELECT w_id, COUNT(DISTINCT date) as wc 
                FROM daily_words
                GROUP BY w_id
        ) AS word_counts ON word_counts.w_id=daily_words.w_id
) ON DUPLICATE KEY UPDATE relative_document_frequency=values(relative_document_frequency);







-- Z-Score
--=========

INSERT INTO aliss15a_daily_words (w_id, date, z_score) (
    SELECT 
            now.w_id,
            now.date, 
            ((now.relative_freq - ref_aliss.mean) / ref_aliss.standard_derivation)
        
        FROM aliss15a_daily_words as now
        JOIN words as now_words on now_words.w_id = now.w_id
        JOIN deu_news_2014.words as ref on now_words.word = ref.word
        JOIN deu_news_2014.aliss15a_words as ref_aliss on ref.w_id = ref_aliss.w_id 
) ON DUPLICATE KEY UPDATE z_score=values(z_score);


SELECT @threshold:=(
    SELECT AVG(mean) 
        FROM deu_news_2014.aliss15a_words 
        WHERE relative_document_frequency < 0.1
);
SELECT 
            now.z_score,
            now_daily_words.freq,
            now_words.word
        
        FROM aliss15a_daily_words as now
        JOIN daily_words as now_daily_words on now.w_id = now_daily_words.w_id and now.date = now_daily_words.date
        JOIN words as now_words on now_words.w_id = now.w_id
        JOIN deu_news_2014.words as ref on now_words.word = ref.word
        JOIN deu_news_2014.aliss15a_words as ref_aliss on ref.w_id = ref_aliss.w_id
        WHERE now.date=Date("2015-10-31") AND ((now.relative_freq > (@threshold*10) AND ref_aliss.relative_document_frequency < 0.1) OR ref_aliss.relative_document_frequency >= 0.1)  
        ORDER BY now.z_score desc
        LIMIT 100;
        
        
-- TF IDF
-- ======

-- INSERT tf_idf to aliss15a_daily_words for all dates (time: 2015 17 min)
INSERT INTO aliss15a_daily_words (w_id, date, tf_idf) (
    SELECT  now.w_id,
            now.date,  
            now.relative_freq * log(1/ref_aliss.relative_document_frequency) AS tf_idf
            FROM  aliss15a_daily_words AS now
            LEFT OUTER JOIN words as now_words on now_words.w_id = now.w_id
            LEFT OUTER JOIN deu_news_2014.words as ref on now_words.word = ref.word
            LEFT OUTER JOIN deu_news_2014.aliss15a_words as ref_aliss on ref.w_id = ref_aliss.w_id
) ON DUPLICATE KEY UPDATE tf_idf=VALUES(tf_idf); 



SELECT 
        now.tf_idf,
        now_daily_words.freq,
        now_words.word
    FROM aliss15a_daily_words as now
    JOIN daily_words as now_daily_words on now.w_id = now_daily_words.w_id and now.date = now_daily_words.date
    JOIN words as now_words on now_words.w_id = now.w_id
    WHERE now.date=Date("2015-10-31")
    ORDER BY now.tf_idf desc
    LIMIT 100;

        
        
-- POISSON NEU  (inkl freqration neu) 
-- ==================================
 
SELECT @total_frequence_2014 := (
    SELECT       SUM(freq) 
    FROM         deu_news_2014.words 
    WHERE        w_id >  30
    ) AS total_freq_2014;

INSERT INTO aliss15a_daily_words (w_id, date, poisson, freqratio) (
    SELECT  words2015.w_id, 
            day.date,
            day.freq * (log(day.freq)-log(daily_freq_sums.freq_sum * (year.freq+day.freq)/@total_frequence_2014)-1) / log(daily_freq_sums.freq_sum) AS poisson,
            (@total_frequence_2014/daily_freq_sums.freq_sum) * day.freq / year.freq AS freqratio 
    FROM    daily_words day
            LEFT OUTER JOIN  words words2015 
            ON               words2015.w_id=day.w_id 
            LEFT OUTER JOIN   deu_news_2014.words year 
            ON                words2015.word = year.word 
            JOIN  ( SELECT       date, SUM(freq) freq_sum
                    FROM         daily_words 
                    WHERE w_id > 30
                    GROUP BY date) daily_freq_sums 
            ON daily_freq_sums.date = day.date
) ON DUPLICATE KEY UPDATE poisson=VALUES(poisson), freqratio = VALUES(freqratio);


SELECT 
        now.poisson,
        now_daily_words.freq,
        now_words.word
    FROM aliss15a_daily_words as now
    JOIN daily_words as now_daily_words on now.w_id = now_daily_words.w_id and now.date = now_daily_words.date
    JOIN words as now_words on now_words.w_id = now.w_id
    WHERE now.date=Date("2015-10-31")
    ORDER BY now.poisson desc
    LIMIT 100;
    
    
    
    
    
-- FREQURATION
--============

INSERT INTO aliss15a_daily_words (w_id, date, freqratio) (
    SELECT 
            now.w_id,
            now.date, 
            (now.relative_freq / ref_aliss.mean)
        
        FROM aliss15a_daily_words as now
        JOIN words as now_words on now_words.w_id = now.w_id
        JOIN deu_news_2014.words as ref on now_words.word = ref.word
        JOIN deu_news_2014.aliss15a_words as ref_aliss on ref.w_id = ref_aliss.w_id 
) ON DUPLICATE KEY UPDATE freqratio=values(freqratio);


SELECT 
        now.freqratio,
        now_daily_words.freq,
        now_words.word
    FROM aliss15a_daily_words as now
    JOIN daily_words as now_daily_words on now.w_id = now_daily_words.w_id and now.date = now_daily_words.date
    JOIN words as now_words on now_words.w_id = now.w_id
    WHERE now.date=Date("2015-10-31")
    ORDER BY now.freqratio desc
    LIMIT 100;


-- INDEXIERUNG VERBESSERN
-- Auf der Daily_words sollte ein index auf w_id und ein index auf date liegen um die Abfragen schneller zu machen
-- Habe indexierung in CREATE TABLE aufgenommen (@wolfo)
ALTER TABLE aliss15a_daily_words ADD KEY(w_id) USING HASH; -- nicht mehr noetig, wenn foreign key bei CREATE TABLE angegeben wird
ALTER TABLE aliss15a_daily_words ADD KEY(date); -- 

 
-- Regex 
 
 '^[[:digit:]]{2}.[[:digit:]]{2}(.[[:digit:]]{2,4})?$' -- filters dates 12.04, 12.04.15, 12.04.2015
 '^[[:digit:]]{2}.[[:blank:]]?(Januar|Februar|März|April|Mai|Juni|Juli|August|September|Oktober|November|Dezember)$' -- filters dates 12. April
 '[[:digit:]]{2}:[[:digit:]]{2}' -- filters time statements
 '[[:digit:]]{2}[[:blank:]]?°C?' -- filters temperature statements
 
 
 SET lc_time_names = 'de_DE';
 CONCAT("^(",
    CONCAT_WS("|",
        DATE_FORMAT(CURDATE(),"%d.%c.%Y"),
        DATE_FORMAT(CURDATE(),"%d.%c.%y"),
        DATE_FORMAT(CURDATE(),"%d.%c"),
        DATE_FORMAT(CURDATE(),"%d. %M"),
        DATE_FORMAT(CURDATE()-1,"%d.%c.%Y"),
        DATE_FORMAT(CURDATE()-1,"%d.%c.%y"),
        DATE_FORMAT(CURDATE()-1,"%d.%c"),
        DATE_FORMAT(CURDATE()-1,"%d. %M"),
        DATE_FORMAT(CURDATE()+1,"%d.%c.%Y"),
        DATE_FORMAT(CURDATE()+1,"%d.%c.%y"),
        DATE_FORMAT(CURDATE()+1,"%d.%c")
        DATE_FORMAT(CURDATE()+1,"%d. %M"),
    ),
    ")$");
    
 
 
 