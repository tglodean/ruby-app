class MicropostsController < ApplicationController
	before_action :signed_in_user, only: [:create, :destroy]
	before_action :correct_user,   only: :destroy
	# before_action :reply_to_user, only: :create

	def create
		@micropost = current_user.microposts.build(micropost_params)
		reply_to_user
		if @micropost.save
			flash[:success] = "Micropost created!"
			redirect_to root_url
		else
			@feed_items = []
			render 'static_pages/home'
		end
	end

	def destroy
		@micropost.destroy
		redirect_to root_url
	end

	private

	def micropost_params
		params.require(:micropost).permit(:content)
	end
	
	def correct_user
		@micropost = current_user.microposts.find(params[:id])
	rescue
		redirect_to root_url
	end

	def reply_to_user

		if reply_to = @micropost.content.match(/@\w+/i)
			@other_user = User.where(name: reply_to.to_s[1..-1]).first
			# print @other_user
			if @other_user && current_user.followed_users.includes(@other_user)
				@micropost.to_id = @other_user.id
			end
		end
	end

end