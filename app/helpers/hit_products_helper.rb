module HitProductsHelper
    def auth_user_check(header_auth_token)
        if header_auth_token != nil
            @user = AppUser.jwt_authenticate_check(header_auth_token)
            return @user
        else
            return false
        end
    end
    
    def product_json(data)
        data = data.to_json(:except => [:id, :created_at, :updated_at, :website, :is_sold_out, :image_url, :redirect_url, :dead_check, :is_title_changed, :shortDate, :date])
        
        return data
    end
    
    def attr_refactory(data, user)
        dataArr = Array.new
        @stackNumber = 1
        data.each do |currentData|
            dataArr.push([@stackNumber, currentData.product_id, currentData.title, currentData.view, currentData.comment, currentData.like, currentData.score, "#{time_ago_in_words(currentData.date)} 전", currentData.image_url, currentData.is_sold_out, currentData.dead_check, currentData.is_title_changed, currentData.url, currentData.redirect_url, currentData.id])
            @stackNumber += 1
        end
        
        resultArr = Array.new
        dataArr.each do |t|
          if user == false
              resultArr.push(:order => t[0], :productId => t[1], :title => t[2], :view => t[3], :comment => t[4], :like => t[5], :score => t[6], :dateAgo => t[7], :imageUrl => t[8], :isSoldOut => t[9], :isDeleted => t[10], :isTitleChanged => t[11], :url => t[12], :shortUrl => t[13], :isBookmark => nil)
          else
              resultArr.push(:order => t[0], :productId => t[1], :title => t[2], :view => t[3], :comment => t[4], :like => t[5], :score => t[6], :dateAgo => t[7], :imageUrl => t[8], :isSoldOut => t[9], :isDeleted => t[10], :isTitleChanged => t[11], :url => t[12], :shortUrl => t[13], :isBookmark => false)
          end
        end

        if user != false
            BookMark.eager_load(:hit_product).where(app_user: user).each do |t|

              bookmarkedData = resultArr.select {|data| data[:productId] == t.hit_product.product_id }.first
              if bookmarkedData != nil
                bookmarkedData[:isBookmark] = true
              end
            end
        end
        
        return resultArr
    end
    
    def bookmark_list_data_push(data)
        jsonArr = Array.new
        jsonArr.push(:order => data[0], :productId => data[1], :title => data[2], :view => data[3], :comment => data[4], :like => data[5], :score => data[6], :dateAgo => data[7], :imageUrl => data[8], :isSoldOut => data[9], :isDeleted => data[10], :isTitleChanged => data[11], :url => data[12], :shortUrl => data[13], :isBookmark => true)
        return jsonArr
    end
    
    def keyword_pushalarm_list_data_push(data, userId)
        jsonArr = Array.new
        
        if BookMark.find_by(app_user_id: userId, hit_product_id: data[14]).nil?
            jsonArr.push(:order => data[0], :productId => data[1], :title => data[2], :view => data[3], :comment => data[4], :like => data[5], :score => data[6], :dateAgo => data[7], :imageUrl => data[8], :isSoldOut => data[9], :isDeleted => data[10], :isTitleChanged => data[11], :url => data[12], :shortUrl => data[13], :isBookmark => false)
        else
            jsonArr.push(:order => data[0], :productId => data[1], :title => data[2], :view => data[3], :comment => data[4], :like => data[5], :score => data[6], :dateAgo => data[7], :imageUrl => data[8], :isSoldOut => data[9], :isDeleted => data[10], :isTitleChanged => data[11], :url => data[12], :shortUrl => data[13], :isBookmark => true)
        end
        
        return jsonArr
    end
end
