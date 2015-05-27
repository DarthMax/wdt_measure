
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

INSERT INTO aliss15a_daily_words (w_id,date,relative_freq) (
    SELECT w_id, daily_words.date, (freq/daily_sums.sum) 
        FROM daily_words 
            JOIN (SELECT date, SUM(freq) as sum FROM daily_words GROUP BY date) AS daily_sums ON daily_sums.date=daily_words.date
);


-- Berechne Erwartungswert und Standardabweichung pro Wort (15 min für 2014)
INSERT INTO aliss15a_words (w_id,mean,standard_derivation) (
    SELECT w_id, AVG(relative_freq), STD(relative_freq) 
        FROM aliss15a_daily_words 
        GROUP BY w_id
);


-- Berechne Dokumentenhäufigkeit pro Wort (Dokument = 1 Tag) (13 min für 2014)
INSERT INTO aliss15a_words (w_id,relative_document_frequency) ( 
    SELECT daily_words.w_id, (word_counts.wc/COUNT(DISTINCT date)) 
        FROM daily_words
        JOIN (
            SELECT w_id, COUNT(DISTINCT date) as wc 
                FROM daily_words
                GROUP BY w_id
        ) AS word_counts ON word_counts.w_id=daily_words.w_id
) ON DUPLICATE KEY UPDATE relative_document_frequency=values(relative_document_frequency);



-- Calculate Z-Score pro Wort und Tag für 2015
INSERT INTO aliss15a_daily_words (w_id, date, z_score) (
    SELECT now.w_id, now.date, 
            ((now.relative_freq - ref_aliss.mean) / ref_aliss.standard_derivation)
        FROM aliss15a_daily_words as now
        JOIN words as now_words on now_words.w_id = now.w_id
        JOIN deu_news_2014.words as ref on now_words.word = ref.word
        JOIN deu_news_2014.aliss15a_words as ref_aliss on ref.w_id = ref_aliss.w_id
);
