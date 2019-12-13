## rake auto_delete:auto_job

namespace :auto_delete do
  desc "TODO"
  task auto_job: :environment do
    	
	def auto_delete
		HitProduct.where('created_at < ?', 10.days.ago).each do |x|
		  x.destroy
		end
	end
	
	auto_delete
    
  end

end
