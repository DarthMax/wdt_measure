
-- in deu_news_2014

-- Tabelle für vorberechnete Werte
CREATE TABLE aliss15a_words (
    w_id INT(10) UNSIGNED PRIMARY KEY,
    relative_document_frequency FLOAT, -- Anzahl der Tage an denen wort Vorkommt / 365ish
    mean FLOAT,
    standard_derivation FLOAT,
    FOREIGN KEY (w_id)  
        REFERENCES words(w_id),
);

-- Tabelle für vorberechnete relative Häufigkeiten, etc..
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



-- Berechne Relative Wortfrequenz pro Wort und Tag (7min für 2014)

select @der_id:=(select w_id from words where word='der');

INSERT INTO aliss15a_daily_words (w_id,date,relative_freq) (
    SELECT w_id, daily_words.date, (freq/daily_sums.sum) 
        FROM daily_words 
            JOIN (SELECT date, freq FROM daily_words WHERE w_id=@der_id) AS daily_der ON daily_der.date=daily_words.date
) ON DUPLICATE KEY UPDATE relative_freq=values(relative_freq);


-- Berechne Erwartungswert und Standardabweichung pro Wort (15 min für 2014)
INSERT INTO aliss15a_words (w_id,mean,standard_derivation) (
    SELECT w_id, AVG(relative_freq), STD(relative_freq) 
        FROM aliss15a_daily_words 
        GROUP BY w_id
) ON DUPLICATE KEY UPDATE mean=values(mean), standard_derivation=values(standard_derivation);


-- Berechne Dokumentenhäufigkeit pro Wort (Dokument = 1 Tag) (13 min für 2014)
INSERT INTO aliss15a_words (w_id,relative_document_frequency) ( 
    SELECT daily_words.w_id, (word_counts.wc/(SELECT COUNT(DISTINCT date) from daily_words)) 
        FROM daily_words
        JOIN (
            SELECT w_id, COUNT(DISTINCT date) as wc 
                FROM daily_words
                GROUP BY w_id
        ) AS word_counts ON word_counts.w_id=daily_words.w_id
) ON DUPLICATE KEY UPDATE relative_document_frequency=values(relative_document_frequency);



-- Calculate Z-Score pro Wort und Tag für 2015
-- ACHTUNG @max from @wolfo: JOIN verschluckt Woerter, die  nicht in 2014 sind (LEFT OUTER JOIN?)
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
    SELECT AVG(daily_words.relative_freq) 
        FROM deu_news_2014.aliss15a_words words 
            JOIN deu_news_2014.aliss15a_daily_words daily_words ON daily_words.w_id=words.w_id
        WHERE words.relative_document_frequency < 0.1
);
SELECT 
            now.z_score,
            now_daily_words.freq,
            now.relative_freq,
            ref_aliss.mean,
            ref_aliss.standard_derivation,
            ref_aliss.relative_document_frequency,
            ref.word,
            now_words.word
        
        FROM aliss15a_daily_words as now
        JOIN daily_words as now_daily_words on now.w_id = now_daily_words.w_id and now.date = now_daily_words.date
        JOIN words as now_words on now_words.w_id = now.w_id
        JOIN deu_news_2014.words as ref on now_words.word = ref.word
        JOIN deu_news_2014.aliss15a_words as ref_aliss on ref.w_id = ref_aliss.w_id
        WHERE now.date=Date("2015-01-01") AND ((now.relative_freq > (@threshold*10) AND ref_aliss.relative_document_frequency < 0.1) OR ref_aliss.relative_document_frequency >= 0.1)  
        ORDER BY now.z_score desc
        LIMIT 100;
        
        
-- TF IDF
-- ======

-- INSERT tf_idf to aliss15a_daily_words for all dates
INSERT INTO aliss15a_daily_words (w_id, date, tf_idf) (
    SELECT now.date, 
        now.w_id, 
        ref.word,  
        now.relative_freq * log(1/ref_aliss.relative_document_frequency) AS tf_idf
        FROM  aliss15a_daily_words AS now
        LEFT OUTER JOIN words as now_words on now_words.w_id = now.w_id
        LEFT OUTER JOIN deu_news_2014.words as ref on now_words.word = ref.word
        LEFT OUTER JOIN deu_news_2014.aliss15a_words as ref_aliss on ref.w_id = ref_aliss.w_id
        ORDER BY    tf_idf 
        DESC 
        LIMIT 20 ;
) ON DUPLICATE KEY UPDATE tf_idf=VALUES(tf_idf); 


-- POISSON NEU  (inkl freqration neu)
-- ==================================

 
SELECT @total_frequence_2014 := (
    SELECT       SUM(freq) 
    FROM         deu_news_2014.words 
    WHERE        w_id >  30
    ) AS total_freq_2014;

INSERT INTO aliss15a_daily_words (w_id, date, poisson, freqratio) (
    SELECT  words2015.w_id, 
            freqratio = (@total_frequence_2014/daily_freq_sums.freq_sum) * day.freq / year.freq AS freqratio,
            day.freq * (log(day.freq)-log(daily_freq_sums.freq_sum * (year.freq+day.freq)/@total_frequence_2014)-1) / log(daily_freq_sums.freq_sum) AS poisson 
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





-- INDEXIERUNG VERBESSERN
-- Auf der Daily_words sollte ein index auf w_id und ein index auf date liegen um die Abfragen schneller zu machen
-- Habe indexierung in CREATE TABLE aufgenommen (@wolfo)
ALTER TABLE aliss15a_daily_words ADD KEY(w_id); -- nicht mehr noetig, wenn foreign key bei CREATE TABLE angegeben wird
ALTER TABLE aliss15a_daily_words ADD KEY(date); -- 

ALTER TABLE aliss15a_daily_words ADD freqratio FLOAT;