# Web page performance metrics testing tool.

There are some exceptions in running this script as it is being continuously developed.
1. In SimplerMailer.rb replace ":user_name => 'EMAIL',:password => 'PASSWORD'"
   with your FULL email (example@gmail.com) and password for your gmail smtp settings.

2. To run script (inside the directory): ruby url_file_scraper.rb

3. You can adjust browser timeout on line 17:=> (timeout: 60)

4. "require_relative 'SimpleMailerurl'" in url_file_scraper.rb is not a mistake.
   You need to include this call to load the Simple Mailer file or you will get an error.

5. Include either "http" or "https" for your url text entries.