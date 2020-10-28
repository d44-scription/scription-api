# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :fetch_notebook
  before_action :fetch_item, only: %i[show update destroy]

  def index
    @items = @notebook.items
  end

  def create
    @item = @notebook.items.new(item_params)

    if @item.save
      render :show, status: :created
    else
      render json: @item.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    if @item.update(item_params)
      render :show, status: :ok
    else
      render json: @item.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
  end

  private

  def fetch_notebook
    @notebook = Notebook.find(params[:notebook_id])
  end

  def fetch_item
    @item = @notebook.items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :description, :notebook_id)
  end
end
