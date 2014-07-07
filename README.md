socialRinsight
==============

socialRinsight is a tool for analytics professionals to quickly scrape social insights data as cleaned data frames for analysis in R. For example, you might want to:

<ul> 
<li> Pull a report on multiple brands from Facebook Insights instead of manually pulling each brand
<li> Set the script to automatically run for fixed-cadence reporting on your managed brands
<li> Analyze your competitors' activity on social media
</ul>





Pull page-level data on Facebook for your brand, examplebrand, for March 2014:
    
    fbpage("examplebrand", "2014-03-01", "2014-04-01", access_token)
    

Pull post level data for your brand, examplebrand, for the first 2 weeks of March 2014:
    
    fbPost("examplebrand", "2014-03-01", "2014-03-15", access_token)

Note: 
<ul>
<li>you must have the correct admin rights for your brand's Facebook page to execute any queries
<li>access_token is your access token available at http://developers.facebook.com/tools/explorer
<li>please consult http://developers.facebook.com/docs/graph-api for more information
</ul>





**Currently socialRinsight only supports Facebook with Twitter support coming soon**



  


