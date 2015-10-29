SELECT
   w.w_id, w.word,
   substring_index(substring_index(replace(so.source, 'http://', ''), '/', 1), '?', 1) as site,
   count(*) as freq
FROM
   words w
   JOIN daily_words dw ON w.w_id = dw.w_id
   JOIN inv_w ON w.w_id = inv_w.w_id
   JOIN sentences s ON inv_w.s_id = s.s_id
   JOIN inv_so ON s.s_id = inv_so.s_id
   JOIN sources so ON inv_so.so_id = so.so_id
WHERE
   dw.date = CURDATE() - INTERVAL 1 DAY AND dw.w_id = 958923
GROUP BY w.w_id, site
ORDER BY w.w_id, freq DESC;


-- Especially on frequent word it takes very long because the are in many senteces (Biggest table) 27000000 sentences till now in 2015
-- For example for word id=30 wort der it takes: 5 min and 30 seconds (638 sources are found)
SELECE words_by_sources.id, words_by_sources.word, count(*) AS source_freq
FROM (
SELECT DISTINCT
   w.w_id AS id, w.word AS word,
   (substring_index(substring_index(replace(so.source, 'http://', ''), '/', 1), '?', 1)) as site
FROM
   words w
   JOIN daily_words dw ON w.w_id = dw.w_id
   JOIN inv_w ON w.w_id = inv_w.w_id
   JOIN sentences s ON inv_w.s_id = s.s_id
   JOIN inv_so ON s.s_id = inv_so.s_id
   JOIN sources so ON inv_so.so_id = so.so_id
WHERE
   dw.date = CURDATE() - INTERVAL 1 DAY AND dw.w_id > 30 AND dw.w_id < 32
   ) AS words_by_sources
   GROUP BY words_by_sources.id
   ORDER BY source_freq
   ;


-- Faster with only sentences where sources have date from today
SELECT count(*)
FROM 
   sentences s
   JOIN inv_so ON s.s_id = inv_so.s_id
   JOIN sources so ON inv_so.so_id = so.so_id
WHERE so.date =  CURDATE() - INTERVAL 1 DAY 

-- Count all sources from yesterdayi
-- Tested on 1000 words it was 630 (7 Minutes and 15 sec) id 9000 to 10000
-- Inconsistently if date is selected on source there where only 211 date != date
SELECT count(*) AS source_count
FROM (
SELECT DISTINCT
--   w.w_id AS id, w.word AS word,
   (substring_index(substring_index(replace(so.source, 'http://', ''), '/', 1), '?', 1)) as site
FROM
   words w
   JOIN daily_words dw ON w.w_id = dw.w_id
   JOIN inv_w ON w.w_id = inv_w.w_id
   JOIN sentences s ON inv_w.s_id = s.s_id
   JOIN inv_so ON s.s_id = inv_so.s_id
   JOIN sources so ON inv_so.so_id = so.so_id
WHERE
   dw.date = CURDATE() - INTERVAL 1 DAY AND dw.w_id > 9000 AND dw.w_id < 10000
   AND so.date =  CURDATE() - INTERVAL 1 DAY 
   ) AS words_by_sources
   ;
