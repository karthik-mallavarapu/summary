class DigestGenerator

  @queue = "digest_gen_queue"

  def self.perform
    news_digest = NewsDigest.new
    news_digest.generate_digest
  end

end