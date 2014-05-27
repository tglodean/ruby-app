class EmailConfirmationsController < ApplicationController
	def new
	end

	def edit
		@user = User.find_by_email_confirm_token!(params[:id])
		if @user.toggle!(:user_state)
			flash[:success] = "Email successfully checked"
			sign_in(@user)
		else
			flash[:error] = "Email not valid"
		end
		redirect_to root_url
	end
end