require "tzinfo"
 
def local(time)
        TZInfo::Timezone.get('Asia/Seoul').local_to_utc(Time.parse(time))
end

every 1.day, at: ['10:00 am', '11:00 am', '12:00 pm', '1:00 pm', '2:00 pm', '3:00 pm', '4:00 pm', '5:00 pm', '6:00 pm', '7:00 pm', '8:00 pm', '9:00 pm', '10:00 pm', '11:00 pm'] do
#   command "/usr/bin/some_great_command"
#   runner "..."
    command "test"
end