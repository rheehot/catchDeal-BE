json.extract! notice, :id, :user_id, :title, :category, :content, :created_at, :updated_at
json.url notice_url(notice, format: :json)
