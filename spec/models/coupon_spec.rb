require "rails_helper"

RSpec.describe Coupon, type: :model do
  describe 'relationships' do
    it { should have_many :invoices }
    it { should belong_to :merchant }
  end

  describe 'validations' do
    let(:merchant) { create(:merchant) }
    subject { Coupon.create(name: 'Coupon 1', code: 'ABC', discount_type: 'dollar_off', discount_value: 10, status: 'active', merchant_id: merchant.id) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code) }
    it { should validate_presence_of(:discount_type) }
    it { should validate_inclusion_of(:discount_type).in_array(%w[percent_off dollar_off]) }
    it { should validate_presence_of(:discount_value) }
    it { should validate_numericality_of(:discount_value).is_greater_than(0) }
    it { should validate_inclusion_of(:status).in_array(%w[active inactive]) }
  end

  describe 'custom validations' do
    let(:merchant) { create(:merchant) }
    
    it 'allows up to 5 active coupons per merchant' do
      create(:coupon, name: 'Coupon 1', status: "active", merchant: merchant)
      create(:coupon, name: 'Coupon 2', status: "active", merchant: merchant)
      create(:coupon, name: 'Coupon 3', status: "active", merchant: merchant)
      create(:coupon, name: 'Coupon 4', status: "active", merchant: merchant)
      coupon5 = create(:coupon, name: 'Coupon 5', status: "active", merchant: merchant)

      expect(coupon5).to be_valid
    end
  

    it 'does not allow a merchant to have more than 5 active coupons' do
      create(:coupon, name: 'Coupon 1', status: "active", merchant: merchant)
      create(:coupon, name: 'Coupon 2', status: "active", merchant: merchant)
      create(:coupon, name: 'Coupon 3', status: "active", merchant: merchant)
      create(:coupon, name: 'Coupon 4', status: "active", merchant: merchant)
      create(:coupon, name: 'Coupon 5', status: "active", merchant: merchant)
      coupon6 = build(:coupon, name: 'Coupon 6', status: "active", merchant: merchant)

      expect(coupon6).not_to be_valid
      expect(coupon6.errors[:status]).to include('cannot be set to active. Merchant already has 5 active coupons.')
    end

    it 'allows as many inactive coupons as wanted' do
      create(:coupon, name: 'Coupon 1', merchant: merchant)
      create(:coupon, name: 'Coupon 2', merchant: merchant)
      create(:coupon, name: 'Coupon 3', merchant: merchant)
      create(:coupon, name: 'Coupon 4', merchant: merchant)
      create(:coupon, name: 'Coupon 5', merchant: merchant)
      coupon6 = build(:coupon, name: 'Coupon 5', merchant: merchant)

      expect(coupon6).to be_valid
    end
  end
end