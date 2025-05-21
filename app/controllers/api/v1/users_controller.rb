module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user

      def dashboard
        render json: {
          user: current_user.as_json(only: [:id, :name, :email, :mobile, :created_at, :updated_at, :profile_image_url]),
          session_expires_at: 24.hours.from_now
        }
      end

      def profile
        render json: {
          user: current_user.as_json(only: [:id, :name, :email, :mobile, :created_at, :updated_at, :profile_image_url])
        }
      end

      def update_profile
        if current_user.update(user_params)
          render json: {
            message: 'Profile updated successfully',
            user: current_user.as_json(only: [:id, :name, :email, :mobile, :created_at, :updated_at, :profile_image_url])
          }
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:name, :mobile, :profile_image)
      end
    end
  end
end 