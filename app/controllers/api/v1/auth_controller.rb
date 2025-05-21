module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user, only: [:register, :login]

      def register
        user = User.new(user_params)

        if user.save
          render json: { message: 'Registration successful', data: user}, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        if params[:google_token]
          handle_google_login
        else
          handle_email_login
        end
      end

      private

      def user_params
        params.permit(:name, :email, :mobile, :password, :password_confirmation, :profile_image)
      end

      def handle_email_login
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          render json: {
            token: generate_token(user),
            user: user
          }
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      def handle_google_login
        begin
          payload = Google::Auth::IDTokens.verify_oidc(params[:google_token], aud: ENV['GOOGLE_CLIENT_ID'])
          user = User.find_or_create_by(email: payload['email']) do |u|
            u.name = payload['name']
            u.password = SecureRandom.hex(16)
            u.mobile = '0000000000' # Default mobile number for Google users
          end
          render json: {
            token: generate_token(user),
            user: user
          }
        rescue Google::Auth::IDTokens::VerificationError
          render json: { error: 'Invalid Google token' }, status: :unauthorized
        end
      end

      def generate_token(user)
        JWT.encode(
          {
            user_id: user.id,
            exp: 24.hours.from_now.to_i
          },
          Rails.application.credentials.secret_key_base
        )
      end
    end
  end
end 