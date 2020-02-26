class Item < ApplicationRecord
  belongs_to :category
  belongs_to :saler
  belongs_to :buyer
  has_many_attached :photos, dependent: :destroy
  # accepts_nested_attributes_for :photos, allow_destroy: true
end
