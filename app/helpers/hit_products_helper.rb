module HitProductsHelper
    def product_json(date)
        date = date.to_json(:methods => [:order, :dateAgo, :imageUrl, :isSoldOut, :isDeleted, :isTitleChanged, :shortUrl], :except => [:id, :created_at, :updated_at, :website, :is_sold_out, :image_url, :redirect_url, :dead_check, :is_title_changed, :shortDate, :date])
        
        return date
    end
    
    def attr_refactory(data)
        @stackNumber = 1
        data.each do |currentData|
            currentData.order = @stackNumber
            currentData.dateAgo = "#{time_ago_in_words(currentData.date)} 전"
            currentData.imageUrl = currentData.image_url
            currentData.isSoldOut = currentData.is_sold_out
            currentData.isDeleted = currentData.dead_check
            currentData.shortUrl = currentData.redirect_url
            currentData.isTitleChanged = currentData.is_title_changed
            @stackNumber += 1
        end
        
        return data
    end
end
