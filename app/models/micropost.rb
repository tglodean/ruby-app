class Micropost < ActiveRecord::Base
	belongs_to :user
	default_scope -> { order('created_at DESC') }
	validates :content, presence: true, length: { maximum: 140 }
	validates :user_id, presence: true

	has_many :replies, foreign_key: "to_id", class_name: "Micropost"
	scope :from_users_followed_by_including_replies, lambda { |user| followed_by_including_replies(user) }

	def self.from_users_followed_by(user)
		followed_user_ids = user.followed_user_ids
		where("user_id IN (:followed_user_ids) OR user_id = :user_id",
			followed_user_ids: followed_user_ids, user_id: user)
	end

	def self.followed_by_including_replies(user)
		followed_ids = %(SELECT followed_id FROM relationships
			WHERE follower_id = :user_id)
	where("user_id IN (#{followed_ids}) OR user_id = :user_id OR to_id = :user_id",
	{ :user_id => user })
	end
end
