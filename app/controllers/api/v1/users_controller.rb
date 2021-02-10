module Api
  module V1
    class UsersController < ApiController
      def show
      end

      def update
        if current_user.update(user_params)
          render :show
        else
          render json: current_user.errors.full_messages, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:display_name, :email, :password)
      end
    end
  end
end
