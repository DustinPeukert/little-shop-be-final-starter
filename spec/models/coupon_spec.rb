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
    before(:each) do
      Merchant.destroy_all
    end
    
    it 'allows up to 5 active coupons per merchant' do
      merchant = Merchant.create!(name: 'Test Merchant')
      
      Coupon.create!(name: 'Coupon 1', code: 'ABC', discount_type: 'dollar_off', discount_value: 10, status: 'active', merchant_id: merchant.id)
      Coupon.create!(name: 'Coupon 2', code: 'DEF', discount_type: 'percent_off', discount_value: 40, status: 'active', merchant_id: merchant.id)
      Coupon.create!(name: 'Coupon 3', code: 'GHI', discount_type: 'percent_off', discount_value: 60, status: 'active', merchant_id: merchant.id)
      Coupon.create!(name: 'Coupon 4', code: 'JKL', discount_type: 'dollar_off', discount_value: 5, status: 'active', merchant_id: merchant.id)
      coupon5 = Coupon.create(name: 'Coupon 5', code: '123', discount_type: 'percent_off', discount_value: 100, status: 'active', merchant_id: merchant.id)

      expect(coupon5).to be_valid
    end
  

    it 'does not allow a merchant to have more than 5 active coupons' do
      merchant = Merchant.create!(name: 'Test Merchant')

      Coupon.create!(name: 'Coupon 1', code: 'MNO', discount_type: 'dollar_off', discount_value: 10, status: 'active', merchant_id: merchant.id)
      Coupon.create!(name: 'Coupon 2', code: 'PQR', discount_type: 'percent_off', discount_value: 40, status: 'active', merchant_id: merchant.id)
      Coupon.create!(name: 'Coupon 3', code: 'STU', discount_type: 'percent_off', discount_value: 60, status: 'active', merchant_id: merchant.id)
      Coupon.create!(name: 'Coupon 4', code: 'VWX', discount_type: 'dollar_off', discount_value: 5, status: 'active', merchant_id: merchant.id)
      Coupon.create!(name: 'Coupon 5', code: 'YZA', discount_type: 'percent_off', discount_value: 100, status: 'active', merchant_id: merchant.id)
      coupon6 = Coupon.create(name: 'Coupon 6', code: '456', discount_type: 'percent_off', discount_value: 50, status: 'active', merchant_id: merchant.id)

      expect(coupon6).not_to be_valid
      expect(coupon6.errors[:status]).to include('cannot be set to active. Merchant already has 5 active coupons.')
    end

    it 'allows as many inactive coupons as wanted' do
      merchant = Merchant.create!(name: 'Test Merchant')

      Coupon.create!(name: 'Coupon 1', code: 'BCD', discount_type: 'dollar_off', discount_value: 10, status: 'inactive', merchant_id: merchant.id)
      Coupon.create!(name: 'Coupon 2', code: 'EFG', discount_type: 'percent_off', discount_value: 40, status: 'inactive', merchant_id: merchant.id)
      Coupon.create!(name: 'Coupon 3', code: 'HIJ', discount_type: 'percent_off', discount_value: 60, status: 'inactive', merchant_id: merchant.id)
      Coupon.create!(name: 'Coupon 4', code: 'KLM', discount_type: 'dollar_off', discount_value: 5, status: 'inactive', merchant_id: merchant.id)
      Coupon.create!(name: 'Coupon 5', code: 'NOP', discount_type: 'percent_off', discount_value: 100, status: 'inactive', merchant_id: merchant.id)
      coupon6 = Coupon.create(name: 'Coupon 6', code: '789', discount_type: 'percent_off', discount_value: 50, status: 'inactive', merchant_id: merchant.id)

      expect(coupon6).to be_valid
    end
  end
end