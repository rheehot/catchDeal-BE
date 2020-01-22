## rake auto_delete:auto_job

namespace :auto_delete do
  desc "TODO"
  task auto_job: :environment do

		def main_auto_delete
			HitProduct.where('created_at < ?', 30.days.ago).each do |x|
				x.destroy
			end
		end
    
  end
end