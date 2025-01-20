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

  def activate
    coupon = Coupon.find(params[:coupon_id])
    if coupon.status == 'active'
      render json: { error: "Coupon is already active" }, status: :unprocessable_entity
    else
      coupon.update(status: 'active')
      render json: CouponSerializer.new(coupon)
    end
  end

  def deactivate
    coupon = Coupon.find(params[:coupon_id])
    if coupon.status == 'inactive'
      render json: { error: "Coupon is already inactive" }, status: :unprocessable_entity
    else
      coupon.update(status: 'inactive')
      render json: CouponSerializer.new(coupon)
    end
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_type, :discount_value, :status)
  end
end
