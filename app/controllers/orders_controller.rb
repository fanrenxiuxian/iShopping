class OrdersController < ApplicationController
  before_action :authenticate_user!, only:[:create, :show]

  def create
    @address = Address.find params[:address_id]
    order = Order.new order_params
    order.address_id = @address.id
    order.user_id = current_user.id
    if order.save
      current_cart.cart_items.each do |cart_item|
        product_list = ProductList.new
        product_list.order_id = order.id
        product_list.picture = cart_item.product.avatar.mini.url
        product_list.product_name = cart_item.product.title
        product_list.product_price = cart_item.product.price
        product_list.product_quantity = cart_item.quantity
        product_list.save
      end
      OrderMailer.notify_order_placed(order).deliver!
      redirect_to order_path(order.token)
      flash[:notice] = "已生成订单！"
    end
  end

  def show
    @order = Order.find_by(token: params[:id])
  end

  def pay_with_wechat
    @order = Order.find_by_token params[:id]
    @order.set_payment_method!("微信")
    @order.make_payment!
    flash[:notice] = "用微信支付成功"
    redirect_to account_orders_path
  end

  def pay_with_alipay
    @order = Order.find_by_token params[:id]
    @order.set_payment_method!("支付宝宝")
    @order.make_payment!
    flash[:notice] = "用支付宝支付成功"
    redirect_to account_orders_path
  end

  def apply_to_cancel
    @order = Order.find params[:id]
    OrderMailer.apply_cancel(@order).deliver!
    flash[:notice] = "已提交申请"
    redirect_back(fallback_location: root_path)
  end

  private
  def order_params
    params.require(:order).permit(:total_money)
  end
end
