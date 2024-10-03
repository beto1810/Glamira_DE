{{ config(
    materialized='table'  
) }}

SELECT DISTINCT 
    product_id,
    name,
    INITCAP(category) as new_category ,
    CASE 
        WHEN LOWER(gender) IN ('male', 'man', 'men', 'masculine', 'mann', 'mand', 'mies') THEN 'Male'
        WHEN LOWER(gender) IN ('female', 'woman', 'feminine', 'donna', "women's", 'vrouw') THEN 'Female'
        ELSE 'Unisex'  -- Optional: To handle any unspecified genders
    END AS gender_group,
    CASE 
        WHEN 
        REGEXP_CONTAINS(LOWER(category), r'\bring\b|\bring\w*') or INITCAP(category) IN ('F Örlovingsrings','Fian Çailles','Wedding Set','Ringer','Wedding Žeds','Bridal Set', 'Engagement', 'Engagement And Gyi Spaces','Damenring','Herrenring','Pier \\ U015bcionki Zar \\ U0119 Discount','Zaru010dou010s Forgiven',"Men's Alliances") THEN 'Rings'
        
        WHEN REGEXP_CONTAINS(LOWER(category), r'\bnecklaces?\b') or INITCAP(category) IN ('Collier','Pearl Pendants','Pendants',"Pearl's Necklaces",'Pendants With Necklaces','Cabochon-Ringe','Circle','Collars')
            THEN 'Necklaces'
        
        WHEN INITCAP(category) IN ('Earring', 'Earrings', 'Nose Pins', 'Nose Earrings', 'Pearl Earrings', 
                          'Diamond Earrings', 'Nose Piercing', 'Nose Piercings', 
                          'Simple Earrings', 'Plain Design Earrings', 'Earrings with Pearl') 
                          or  REGEXP_CONTAINS(LOWER(category), r'\bearrings?\b')
            THEN 'Earrings'

        WHEN TRIM(INITCAP(category)) IN ('Bracelet', 'Bracelets', 'Ankle Jewelry', 'Ankle Chain', 
                          'Simple Design Bracelets', 'Plain Design Bracelets', 
                          'Initial & Name Bracelets', 'Simple Design Bracelet', 
                          'Arm Jewelry','Bricks For Ankle','Arm Jewel') or  REGEXP_CONTAINS(LOWER(category), r'\bbracelets?\b')
            THEN 'Bracelets'
        
        WHEN TRIM(INITCAP(category)) IN ('Cufflink', 'Cufflinks', 'Cuff buttons', 'Cuff Buttons' , 'Pins' , 'Pin M \\ U169i', 'Simple Design Cufflinks') 
            THEN 'Cufflinks'
        
        WHEN INITCAP(category) IN ('Brooch', 'Brooches', 'Brooches with Initials', 
                          'Brooches with Simple Designs','Broocch') or  REGEXP_CONTAINS(LOWER(category), r'\bbrooch(?:es)?\b')
            THEN 'Brooches'
        
        WHEN INITCAP(category) IN ('Anklets', 'Anklet') THEN 'Anklets'
        
        ELSE 'Miscellaneous'
    END AS jewelry_category
FROM 
    `dek9-glamira-18.glamira_raw.glamira_product_info`
WHERE 
    name IS NOT NULL AND name != "not found" 
ORDER BY 
    jewelry_category, name
