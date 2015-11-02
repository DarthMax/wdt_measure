-- Especially on frequent word it takes very long because the are in many senteces (Biggest table) 27000000 sentences till now in 2015
-- For example for word id=30 wort der it takes: 5 min and 30 seconds (638 sources are found)
-- After fixing the source date bug 2 minutes and 15 sec. and 216 sources are found
-- 10000 ids 10 000 bis 20 000 27 min
SELECT words_by_sources.id, words_by_sources.word, count(*) AS source_freq
FROM (
SELECT DISTINCT
   w.w_id AS id, w.word AS word, so.domain as site
  -- (substring_index(substring_index(replace(replace(so.source, 'http://', ''), 'https://', ''), '/', 1), '?', 1)) as site
FROM
   words w
   RIGHT JOIN daily_words dw ON w.w_id = dw.w_id
   RIGHT JOIN inv_w ON w.w_id = inv_w.w_id
   RIGHT JOIN sentences s ON inv_w.s_id = s.s_id
   RIGHT JOIN inv_so ON s.s_id = inv_so.s_id
   RIGHT JOIN sources so ON inv_so.so_id = so.so_id
WHERE
   dw.date = CURDATE() - INTERVAL 1 DAY AND dw.w_id > 10000 AND dw.w_id < 20000
   AND so.date =  CURDATE() - INTERVAL 1 DAY 
   ) AS words_by_sources
   GROUP BY words_by_sources.id
   ORDER BY source_freq
   ;

-- Count all sources from one day
SELECT COUNT(*) FROM 
    (SELECT DISTINCT 
        domain 
     FROM     sources  
     WHERE date =  CURDATE() - INTERVAL 2 DAY 
     GROUP BY domain) AS domains;


-- Take top zscore, and multipicate with source_freq/number_of_sources_of_the_day
-- Alternative is not so good: -(log(1- source_freq/number_of_sources_of_the_day)) 
SELECT *, count(*) AS source_freq, words_by_sources.z_score*(count(*)/223) AS z_score_durch_sourcefreq
FROM (
SELECT DISTINCT
   w.w_id AS id, w.word AS word, so.domain as site, top.z_score AS z_score, top.relative_freq AS relative_freq
  -- (substring_index(substring_index(replace(replace(so.source, 'http://', ''), 'https://', ''), '/', 1), '?', 1)) as site
FROM
   words w
   RIGHT JOIN (
        SELECT * FROM aliss15a_daily_words  WHERE date = CURDATE() - INTERVAL 2 DAY ORDER BY z_score DESC LIMIT 200) AS top
     ON top.w_id = w.w_id
   RIGHT JOIN inv_w ON w.w_id = inv_w.w_id
   RIGHT JOIN sentences s ON inv_w.s_id = s.s_id
   RIGHT JOIN inv_so ON s.s_id = inv_so.s_id
   RIGHT JOIN sources so ON inv_so.so_id = so.so_id
WHERE
  -- dw.date = CURDATE() - INTERVAL 1 DAY AND dw.w_id > 10000 AND dw.w_id < 20000 AND
   so.date =  CURDATE() - INTERVAL 2 DAY 
   ) AS words_by_sources
   GROUP BY words_by_sources.id
   ORDER BY z_score_durch_sourcefreq DESC
   ;

-- Count all sources from one day
SELECT COUNT(*) FROM 
    (SELECT DISTINCT 
        domain 
     FROM     sources  
     WHERE date =  CURDATE() - INTERVAL 1 DAY 
     GROUP BY domain) AS domains;
