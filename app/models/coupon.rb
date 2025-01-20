class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :discount_type, presence: true, inclusion: { in: %w[percent_off dollar_off] }
  validates :discount_value, presence:true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[active inactive] }
  validates :merchant, presence: true

  validate :merchant_active_coupon_limit, if: -> { status = 'active' }

  private

  def merchant_active_coupon_limit
    if status == 'active' && merchant.coupons.where(status: 'active').where.not(id: id).count >= 5
      errors.add(:status, "cannot be set to active. Merchant already has 5 active coupons.")
    end
  end
end