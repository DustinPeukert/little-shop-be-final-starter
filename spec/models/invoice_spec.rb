require "rails_helper"

RSpec.describe Invoice do
  it { should belong_to :merchant }
  it { should belong_to :customer }
  it { should belong_to(:coupon).optional(true) }
  it { should validate_inclusion_of(:status).in_array(%w(shipped packaged returned)) }
end