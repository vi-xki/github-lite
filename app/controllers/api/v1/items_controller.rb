module Api
  module V1
    class ItemsController < ApplicationController
      before_action :set_item, only: [:show, :update, :destroy]

      def index
        @items = current_user.items
        render json: @items
      end

      def show
        render json: @item
      end

      def create
        @item = current_user.items.build(item_params)
        if @item.save
          render json: @item, status: :created
        else
          render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @item.update(item_params)
          render json: @item
        else
          render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @item.destroy
        head :no_content
      end

      private

      def set_item
        @item = current_user.items.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Item not found' }, status: :not_found
      end

      def item_params
        params.permit(:title, :description)
      end
    end
  end
end 