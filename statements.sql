
-- in deu_news_2014

-- Tabelle für vorberechnete Werte
CREATE TABLE aliss15a_words (
    w_id INT(10) UNSIGNED PRIMARY KEY,
    relative_document_frequency FLOAT, -- Anzahl der Tage an denen wort Vorkommt / 365ish
    mean FLOAT,
    standard_derivation FLOAT
);

-- Tabelle für vorberechnete relative Häufigkeiten
CREATE TABLE aliss15a_daily_words (
    w_id INT(10) UNSIGNED,
    date date,
    relative_freq FLOAT,
    z_score FLOAT,
    tf_idf FLOAT,
    poisson FLOAT,
    PRIMARY KEY(w_id, date)
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
-- ACHTUNG @max from wolf: JOIN verschluckt Woerter, die  nicht in 2014 sind (LEFT OUTER JOIN?)
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
