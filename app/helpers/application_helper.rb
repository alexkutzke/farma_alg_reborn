module ApplicationHelper

  # Returns the Gravatar for the given user.
  def gravatar_for(user, options = { size: 80, class: "img-circle" })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{options[:size]}"
    image_tag(gravatar_url, alt: user.name, class: options[:class])
  end

  # Returns only the current datetime without separators (e.g., '/', '-').
  def plain_current_datetime(datetime = Time.now)
    datetime.strftime("%Y%m%d%H%M%S")
  end
end
