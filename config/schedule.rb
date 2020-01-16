require "tzinfo"
 
def local(time)
        TZInfo::Timezone.get('Asia/Seoul').local_to_utc(Time.parse(time))
end

every 10.minutes do
#   command "/usr/bin/some_great_command"
#   runner "..."
    command "cd /home/ubuntu/catch && rake hit_news_ppom:auto_collect RAILS_ENV=production; rake hit_news_ruliweb:auto_collect RAILS_ENV=production; rake hit_news_deal_bada:auto_collect RAILS_ENV=production; rake hit_news_ppom:auto_collect RAILS_ENV=production;"
end

every 5.minutes do
    command "cd /home/ubuntu/catch && alive_check:check RAILS_ENV=production; auto_delete:auto_job RAILS_ENV=production"
end

every 1.hours do
    command "cd /home/ubuntu/catch && hit_news_over_ruliweb_check:auto_collect RAILS_ENV=production; hit_news_over_clien_check:auto_collect RAILS_ENV=production; hit_news_over_deal_bada_check:auto_collect RAILS_ENV=production; hit_news_over_ppom_check:auto_collect RAILS_ENV=production;"
end

every 3.hours do
    rake "cd /home/ubuntu/catch && rake chrome_check:auto_job", :environment => "production"
end
