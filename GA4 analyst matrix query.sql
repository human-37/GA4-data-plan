DECLARE
  props STRING;
SET
  props = (
  SELECT
    CONCAT('("', STRING_AGG( key, '", "'), '")'),
  FROM (
    SELECT
      DISTINCT key
    FROM
      `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
      UNNEST(event_params)
    ORDER BY
      key ASC) );
EXECUTE IMMEDIATE
  FORMAT("""
SELECT * FROM
(
  SELECT 
    case when count( event_timestamp ) is not null then "X" 
    else "" end
    as property,
    event_name,
    key
    
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`, unnest(event_params)
  GROUP BY event_name, key
)
PIVOT
(
  max(property)
  FOR key in %s
)
order by event_name

""", props);