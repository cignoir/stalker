module Stalker
  class Post
    attr_accessor :thread_uuid, :uuid
    attr_accessor :number, :user_id, :posted_at, :name, :message

    def initialize(thread_uuid = nil, number = nil, posted_at = nil, name = nil, user_id = nil, message = nil)
      @thread_uuid = thread_uuid
      @uuid = SecureRandom.uuid

      @number = number
      @posted_at = posted_at
      @name = name
      @user_id = user_id
      @message = message
    end
  end
end