
-- Tabelle für vorberechnete Werte
CREATE TABLE aliss15a_words (
    w_id INT(10) UNSIGNED PRIMARY KEY,
    relative_document_frequency FLOAT, -- Anzahl der Tage an denen wort Vorkommt / 365ish
    mean FLOAT,
    standard_derivation FLOAT
);