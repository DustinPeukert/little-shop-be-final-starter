class Api::V1::Merchants::CouponsController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])

    if params[:status].present?
      coupons = merchant.coupons.filter_by_status(params[:status])
    else
      coupons = merchant.coupons
    end

    render json: CouponSerializer.new(coupons.order(:id))
  end

  def show
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.find(params[:id])

    use_count = coupon.invoices.count

    render json: CouponSerializer.new(coupon, meta: { use_count: use_count })
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.new(coupon_params)

    if coupon.save
      render json: CouponSerializer.new(coupon), status: :created
    else
      render json: { errors: coupon.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    coupon = Coupon.find(params[:coupon_id])

    if params[:status] == 'active'
      if coupon.activate
        render json: CouponSerializer.new(coupon)
      else
        render json: { error: "Cannot activate coupon. Already active." }, status: :unprocessable_entity
      end
    elsif params[:status] == 'inactive'
      if coupon.deactivate
        render json: CouponSerializer.new(coupon)
      else
        render json: { error: "Cannot deactivate coupon. Already inactive." }, status: :unprocessable_entity
      end
    else
      render json: { error: "Invalid status" }, status: :unprocessable_entity
    end
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_type, :discount_value, :status)
  end
end
