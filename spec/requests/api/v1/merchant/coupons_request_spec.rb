require "rails_helper"

RSpec.describe "Merchant coupons endpoints" do
  it "should return all coupons for a given merchant" do
    merchant = create(:merchant)
    coupon1 = create(:coupon, status: "active", merchant_id: merchant.id)
    coupon2 = create(:coupon, merchant_id: merchant.id)
    coupon3 = create(:coupon, merchant_id: merchant.id)

    get "/api/v1/merchants/#{merchant.id}/coupons"
    
    coupons = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(coupons[:data].count).to eq(3)

    expect(coupons[:data][0][:id].to_i).to eq(coupon1.id)
    expect(coupons[:data][0][:type]).to eq("coupon")
    expect(coupons[:data][0][:attributes][:name]).to eq(coupon1.name)
    expect(coupons[:data][0][:attributes][:code]).to eq(coupon1.code)
    expect(coupons[:data][0][:attributes][:discount_type]).to eq(coupon1.discount_type)
    expect(coupons[:data][0][:attributes][:discount_value]).to eq(coupon1.discount_value)
    expect(coupons[:data][0][:attributes][:status]).to eq(coupon1.status)

    expect(coupons[:data][2][:id].to_i).to eq(coupon3.id)
    expect(coupons[:data][2][:type]).to eq("coupon")
    expect(coupons[:data][2][:attributes][:name]).to eq(coupon3.name)
    expect(coupons[:data][2][:attributes][:code]).to eq(coupon3.code)
    expect(coupons[:data][2][:attributes][:discount_type]).to eq(coupon3.discount_type)
    expect(coupons[:data][2][:attributes][:discount_value]).to eq(coupon3.discount_value)
    expect(coupons[:data][2][:attributes][:status]).to eq(coupon3.status)
  end
end