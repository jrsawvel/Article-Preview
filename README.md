# Article Preview

Article Preview temporarily creates a single HTML page.

Test site: <http://article.soupmode.com>

Markup is submitted, and a formatted HTML page is returned. 

Custom CSS can be used to override the default CSS.

The markup can contain Markdown, Multimarkdown, or Textile, along with HTML. 

The markup chosen depends upon how the title line is created. The title line is the first line in the markup. If it begins with a pound sign, the markup uses Markdown/MultiMarkdown. If the title line begins with `h1.`, then the markup uses Textile.



### Custom Formatting Commands

These commands can be used within the markup:

* `css. (code) css..`
* `more.`
* `toc=yes|NO`
* `using_css=YES|no`    
* `tint_image_header=yes|NO`   
* `title_over_image=yes|NO`
* `publish_info_at_top=yes|NO`
* `url_to_link=YES|no` 
* `hashtag_to_link=yes|NO`
* `newline_to_br=YES|no`
* `headings_as_links=yes|NO`
* `aside=text`
* `imageheader=url`
* `largeimageheader=url`
* `q. and q..` - highlight text, similar to blockquote
* `br.`
* `hr.`
* `fence. and fence..` 
* `code. and code..`
* `pq. and pq..` - highlight a pull quote
* `insta=<url>` - embed an Instagram photo


### API and JSON

Article Preview can also be accessed through its API, which contains only one command. But it requires JSON to be posted. (To-Do: create an API option that permits a urlencoded POST request.)

Only two JSON name fields need to be submitted, which include `markup` and `submit_type`.

The API endpoint for the test site is:  
`http://article.soupmode.com/api/v1/posts`


Example:

    curl -X POST -H "Content-Type: application/json" --data 'curl -X POST -H "Content-Type: application/json" --data '{"markup":"# Morning notes for Fri, Jan 22, 2016\r\n\r\n*created at 9:15 a.m.* - **updated at 3:40 p.m.** - It was an overcast morning with temps in the low to mid 20s and light wind. Some very light snow fell around daybreak. Another area of light snow should move into Toledo this morning. The snow area came from the east off of Lake Erie.\r\n\r\nmore.\r\n\r\n## 3:40 p.m.\r\n\r\nMostly sunny. Temps near 30 degrees.\r\n\r\n\r\n## 2:50 p.m.\r\n\r\nCloud cover has broken up some over the past 30 minutes. Sky now is partly sunny. Temps were in the upper 20s. Wind speeds have increased during the late morning and early afternoon.\r\n\r\n\r\n## 1:46 p.m\r\n\r\n![](https://c2.staticflickr.com/2/1506/24435045222_e520b5f886_o.gif)\r\n","submit_type":"Preview"}' http://article.soupmode.com/api/v1/posts



Returned JSON:

    {
      "status":200,
      "description":"OK",
      "author":"Nick Adams",
      "title":"Morning notes for Fri, Jan 22, 2016",
      "created_time":"15:47:35 Z",
      "created_date":"Wed, 02 Mar 2016",
      "post_type":"article",
      "reading_time":0,
      "word_count":101,
      "more_text_exists":1,
      "tags":[],
      "toc":0,
      "title_over_image":0,
      "tint_header_image":0,
      "publish_info_at_top":0,
      "using_css":1,
      "custom_css":""
      "text_intro":"created at 9:15 a.m. - updated at 3:40 p.m. - It was an overcast morning with temps in the low to mid 20s and light wind. Some very light snow fell around daybreak. Another area of light snow should move into Toledo this morning. The snow area came from the east off of Lake Erie.",
      "html":"<p><em>created at 9:15 a.m.</em> - <strong>updated at 3:40 p.m.</strong> - It was an overcast morning with temps in the low to mid 20s and light wind. Some very light snow fell around daybreak. Another area of light snow should move into Toledo this morning. The snow area came from the east off of Lake Erie.</p>\n\n<p><more /></p>\n\n<h2>3:40 p.m.</h2>\n\n<p>Mostly sunny. Temps near 30 degrees.</p>\n\n<h2>2:50 p.m.</h2>\n\n<p>Cloud cover has broken up some over the past 30 minutes. Sky now is partly sunny. Temps were in the upper 20s. Wind speeds have increased during the late morning and early afternoon.</p>\n\n<h2>1:46 p.m</h2>\n\n<p><img src=\"https://c2.staticflickr.com/2/1506/24435045222_e520b5f886_o.gif\" alt=\"\" /></p>\n"
    }



### Sample Markup

    # Swan Creek Explorer Tour Boat Ride
    
    css.
    article {
        font-size: 125%;
    }
    css..
    
    Some pics from an August 2006 boat ride, which was a $5 pontoon boat ride up and down Swan Creek in the Warehouse District and then out into the Maumee River from the MLK bridge to the Anthony Wayne bridge and then back to the Erie Street Market.  
    
    more.
    
    It was unfortunately an extremely hazy day, which makes for lousy picture-taking conditions. It's like the sky doesn't exist in these pics. 
    
    And I hopped onto the boat as it was pulling away from the dock, so I was too late to sit in the front row, which is why many pics contain headshots of other people. It just means I will have to take the boat ride again this summer.
    
    The boat ride leaves from the dock, located next to the parking lot in back of the ESM where the farmers market is held. It's a 45 minute boat ride. The Captain gives some history of the area.
    
    tint_header_image=yes
    title_over_image=yes
    
    largeimageheader=http://farm4.static.flickr.com/3142/2608301058_e4e30c31f2_o.jpg
    
    aside=Cruising on a Downtown Creek


