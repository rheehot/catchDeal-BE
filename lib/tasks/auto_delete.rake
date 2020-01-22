<<<<<<< HEAD
## rake auto_delete:auto_job

namespace :auto_delete do
  desc "TODO"
  task auto_job: :environment do

		def main_auto_delete
			HitProduct.where('created_at < ?', 30.days.ago).each do |x|
				x.destroy
			end
		end

		main_auto_delete
    
  end
=======
## rake auto_delete:auto_job

namespace :auto_delete do
  desc "TODO"
  task auto_job: :environment do

		def main_auto_delete
			HitProduct.where('created_at < ?', 30.days.ago).each do |x|
				x.destroy
			end
		end

		main_auto_delete
    
  end
>>>>>>> a996e89d14d635c35879401b787d17c820f64ca0
end