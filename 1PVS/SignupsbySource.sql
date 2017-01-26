with signups as (
SELECT x.start_date_local, 
       x.billing_type_code, 
       y.name, 
       st.reporting_year,
	     st.reporting_week_of_year,
	     ac.attribution_code_type,	
  	   case when ac.attribution_code_description in ('allfreemovi04-20','sport05-20','ovgcom08-20') then 'ASSOCIATES'
            when ac.attribution_code_description in (select distinct store_id from dv_marketing.associate_storeids) then 'ASSOCIATES'
            else ac.attribution_code_category
            end as attribution_code_category,	   
	   case when ac.attribution_code_description in ('allfreemovi04-20') then 'ROUND FOREST'
            when ac.attribution_code_description in ('chilimovie-20') then 'CHILI MOVIE'
            when ac.attribution_code_description in ('sport05-20') then 'YIDIO'
            when ac.attribution_code_description in ('ovgcom08-20') then 'ACCOUNT MANAGED'          
            when ac.attribution_code_description in (select distinct store_id from dv_marketing.associate_storeids) then 'PAID GENERAL ASSOCIATE'
            else ac.attribution_code_subcategory
            end as attribution_code_subcategory,                        
	   ac.attribution_code,		
       ac.attribution_code_description,	
       case when c.device_category in ('Roku') then 'Roku'
            when c.device_category in ('Web') then 'Web'
            when c.device_category in ('iOS Device') then 'iOS'	
            when c.device_category in ('Sony Playstation') then 'Playstation'
            when c.device_category in ('Samsung TV and BD') then 'Samsung TV and BD'
            when c.device_category in ('Kindle Fire') then 'Fire Tablet'
            when c.device_category in ('Vizio TV and BD') then 'Vizio TV and BD'
            when c.device_category in ('Sony Bravia TV and BD') then 'Sony TV and BD'
            when c.device_category in ('Xbox') then 'Xbox'	   
            when c.device_category in ('Android','Android Device') then 'Android'
            when c.device_category in ('FireTV Stick','FireTV') then 'Fire TV/Stick'
            when x.attributed_device_type_id = 'A36B5UCBCZO3WW' then 'Mobile Web'
            else c.device_category
            end as Device,
	   count (distinct x.subscription_id)	Signups									
  FROM DVBI_CORE.FACT_DV_SUBSCRIPTIONS x		  
  JOIN 
       (select *, 
  	           case when attribution_code = 'organic' and attributed_associate_tag is not null then attributed_associate_tag 
	           else attribution_code end as attribution_code02
          from dv_marketing.beta_dv_attribution_signups_LL) s
                                              ON x.subscription_id = s.subscription_id
                                             AND x.start_date_local = s.subs_start_date_local
                                             AND s.attribution_model = 'DVDM_SGP_Signup_Attribution_First_Click_All_Associates' 
  JOIN dvbi_core.dim1_dv_plan_types y on x.plan_type_id = y.plan_type_id
  --New Paid Marketing Attribution Code Table (Part 01 fix)
  LEFT JOIN dv_marketing.beta_dv_attribution_codes_LL AC on s.ATTRIBUTION_CODE02 = AC.ATTRIBUTION_CODE
                                                        and s.MARKETPLACE_ID = AC.MARKETPLACE_ID
  LEFT JOIN dvbi_core.dim1_dv_device_types c on s.attributed_device_type_id = c.device_type_id
  JOIN dv_marketing.o_reporting_days st on x.start_date_local = st.calendar_day   --started happening in that week		    
    
    
 WHERE x.marketplace_id = 1  
   and x.offer_desc in ('3P_SUBS')  
   and x.start_date_local >= to_date('2016/01/01','YYYY/MM/DD') 
   and y.name = 'Anime Strike'
   and x.IS_RAW_PLAN_START = 'Y' )
   
select 
  start_date_local,    
  billing_type_code,
  name, 
  reporting_year,	              
  reporting_week_of_year,
  attribution_code_type,       
  attribution_code_category,
  attribution_code_subcategory, 
  attribution_code,         
  attribution_code_description,
  Device,


count(distinct subscription_id) as num_signups
from signups
group by 1,2,3,4,5,6,7,8,9,10,11

