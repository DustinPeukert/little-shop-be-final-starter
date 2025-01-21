require "rails_helper"

RSpec.describe "Merchant coupons endpoints" do
  it "should return all coupons for a given merchant" do
    merchant = create(:merchant)
    coupon1 = create(:coupon, status: "active", merchant: merchant)
    coupon2 = create(:coupon, merchant: merchant)
    coupon3 = create(:coupon, merchant: merchant)

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

  it "returns only active coupons when filtered by status=active" do
    merchant = create(:merchant)
    create(:coupon, merchant: merchant, status: "active")
    create(:coupon, merchant: merchant, status: "active")
    create(:coupon, merchant: merchant, status: "inactive")

    get "/api/v1/merchants/#{merchant.id}/coupons?status=active"

    coupons = JSON.parse(response.body, symbolize_names: true)
    expect(response).to be_successful

    expect(coupons[:data].size).to eq(2)
    expect(coupons[:data][0][:attributes][:status]).to eq("active")
    expect(coupons[:data][1][:attributes][:status]).to eq("active")
  end

  it "returns only inactive coupons when filtered by status=inactive" do
    merchant = create(:merchant)
    create(:coupon, merchant: merchant, status: "active")
    create(:coupon, merchant: merchant, status: "inactive")
    create(:coupon, merchant: merchant, status: "inactive")

    get "/api/v1/merchants/#{merchant.id}/coupons?status=inactive"

    coupons = JSON.parse(response.body, symbolize_names: true)
    expect(response).to be_successful

    expect(coupons[:data].size).to eq(2)
    expect(coupons[:data][0][:attributes][:status]).to eq("inactive")
    expect(coupons[:data][1][:attributes][:status]).to eq("inactive")
  end

  it "should return a specific coupon and the usage count" do
    merchant = create(:merchant)
    coupon = create(:coupon, merchant: merchant)
    create_list(:invoice, 3, coupon: coupon)
  
    get "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"
  
    response_data = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(response_data[:data][:id].to_i).to eq(coupon.id)
    expect(response_data[:meta][:use_count]).to eq(3)
  end

  it "creates a new coupon for a merchant" do
    merchant = create(:merchant)

    coupon_params = {
      coupon: {
        name: "20 Percent Off",
        code: "20POFF",
        discount_type: "percent_off",
        discount_value: 20,
        status: "active"
      }
    }

    headers = { "CONTENT_TYPE" => "application/json" }

    post "/api/v1/merchants/#{merchant.id}/coupons", headers: headers, params: JSON.generate(coupon_params)

    expect(response).to be_successful
    expect(response.status).to eq(201)

    created_coupon = Coupon.last

    expect(created_coupon.name).to eq("20 Percent Off")
    expect(created_coupon.code).to eq("20POFF")
    expect(created_coupon.discount_type).to eq("percent_off")
    expect(created_coupon.discount_value).to eq(20)
    expect(created_coupon.status).to eq("active")
    expect(created_coupon.merchant_id).to eq(merchant.id)
  end

  it "activates a coupon" do
    merchant = create(:merchant)
    coupon = create(:coupon, merchant: merchant, status: 'inactive')
  
    patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}/update_status", params: { status: 'active' }
  
    expect(response).to be_successful
    response_data = JSON.parse(response.body, symbolize_names: true)
  
    activated_coupon = response_data[:data]
  
    expect(activated_coupon[:id].to_i).to eq(coupon.id)
    expect(activated_coupon[:attributes][:status]).to eq('active')
  end
  
  it "returns an error if the coupon is already active" do
    merchant = create(:merchant)
    coupon = create(:coupon, merchant: merchant, status: 'active')
  
    patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}/update_status", params: { status: 'active' }
  
    expect(response).to have_http_status(:unprocessable_entity)
    error_message = JSON.parse(response.body, symbolize_names: true)
  
    expect(error_message[:error]).to eq("Cannot activate coupon. Already active.")
  end
  
  it "deactivates a coupon" do
    merchant = create(:merchant)
    coupon = create(:coupon, merchant: merchant, status: 'active')
  
    patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}/update_status", params: { status: 'inactive' }
  
    expect(response).to be_successful
    response_data = JSON.parse(response.body, symbolize_names: true)
  
    deactivated_coupon = response_data[:data]
  
    expect(deactivated_coupon[:id].to_i).to eq(coupon.id)
    expect(deactivated_coupon[:attributes][:status]).to eq('inactive')
  end
  
  it "returns an error if the coupon is already inactive" do
    merchant = create(:merchant)
    coupon = create(:coupon, merchant: merchant, status: 'inactive')
  
    patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}/update_status", params: { status: 'inactive' }
  
    expect(response).to have_http_status(:unprocessable_entity)
    error_message = JSON.parse(response.body, symbolize_names: true)
  
    expect(error_message[:error]).to eq("Cannot deactivate coupon. Already inactive.")
  end
end