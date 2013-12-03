# encoding: utf-8
#
# v2 запросы
#
# TODO HTTP Basic Auth
# TODO авторизация конкретных экшнов для разных партнеров
# TODO проверка на SSL
# TODO принимает json в качестве пейлоада
class ApiOrdersController < ApplicationController

  # выдаст список заказов, доступных данному партнеру
  # можно попробовать заменить OrderStatsController
  def index
  end

  # состояние/существование заказа
  def show
    # order = Order.find_by_ref!(params[:id])
    # render json: OrderPresenter.new(order)
  end

  # создает заказ
  def create
    # order = Order.create
    # form = OrderForm.new(params[:order])
    # transition = OrderTransition.new(order: order, form: form)
    # transition.go!
    # render json: OrderPresenter.new(transition.order)
  end

  # апдейтит заказ
  def update
    # order = Order.find_by_ref!(params[:id])
    # form = OrderForm.new(params[:order])
    # transition = OrderTransition.new(order: order, form: form)
    # transition.go!
    # render json: OrderPresenter.new(transition.order)
  end

end
