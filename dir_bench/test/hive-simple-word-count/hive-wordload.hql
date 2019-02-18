CREATE TABLE FILES (line STRING);

LOAD DATA INPATH '/user/input/input-data.txt' OVERWRITE INTO TABLE FILES;

CREATE TABLE word_counts AS
SELECT word, count(1) AS count FROM
(SELECT explode(split(line, ' ')) AS word FROM FILES) w
GROUP BY word
ORDER BY word;