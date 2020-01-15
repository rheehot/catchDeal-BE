require "tzinfo"
 
def local(time)
        TZInfo::Timezone.get('Asia/Seoul').local_to_utc(Time.parse(time))
end

every 10.minutes do
#   command "/usr/bin/some_great_command"
#   runner "..."
    rake "hit_news_ppom:auto_collect", :environment => "production"
    rake "hit_news_clien:auto_collect", :environment => "production"
    rake "hit_news_ruliweb:auto_collect", :environment => "production"
    rake "hit_news_deal_bada:auto_collect", :environment => "production"
end

rake 5.minutes do
    rake "alive_check:check", :environment => "production"
    rake "auto_delete:auto_job", :environment => "production"
end

rake 1.hours do
    rake "hit_news_over_ruliweb_check:auto_collect", :environment => "production"
    rake "hit_news_over_clien_check:auto_collect", :environment => "production"
    rake "hit_news_over_deal_bada_check:auto_collect", :environment => "production"
    rake "hit_news_over_ppom_check:auto_collec", :environment => "production"
end

rake 12.hours do
    rake "rake chrome_check:auto_job", :environment => "production"
end


# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
