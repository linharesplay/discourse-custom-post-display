# name: discourse-custom-post-display
# about: Discourse Custom Post Display plugin
# version: 1.0
# authors: michael@communiteq.com
# url: https://github.com/communiteq/discourse-custom-post-display

enabled_site_setting :custom_post_display_enabled

register_asset 'stylesheets/common/custom-post-display.scss'
register_asset 'stylesheets/desktop/custom-post-display.scss', :desktop
register_asset 'stylesheets/mobile/custom-post-display.scss', :mobile

after_initialize do
  register_svg_icon "calendar-days"
  register_svg_icon "pen-to-square"
  register_svg_icon "thumbs-up"

  add_to_serializer(:post, :user_post_count, false) do
    object&.user&.post_count || 0
  end

  add_to_serializer(:post, :user_topic_count, false) do
    object&.user&.topic_count || 0
  end

  add_to_serializer(:post, :user_likes_received, false) do
    object&.user&.user_stat&.likes_received || 0
  end

  add_to_serializer(:post, :user_join_date, false) do
    "#{object&.user&.created_at&.strftime(SiteSetting.custom_post_display_join_format)}" || "unknown" rescue "bad fmt"
  end

  add_to_serializer(:user, :badges) do
    badges = []

    object.badges.each do |b|
      b.icon.gsub! "fa-", ""
      badges.push(b)
    end

    ActiveModel::ArraySerializer.new(
      badges,
      each_serializer: BadgeSerializer
    ).as_json
  end

  add_to_serializer(:post, :user_badges) do
    ActiveModel::ArraySerializer.new(object&.user&.featured_badges, each_serializer: BadgeSerializer).as_json
  end

  add_to_serializer(:post, :include_user_badges?) do
    object&.user&.featured_badges.present?
  end

  add_to_class(:user, :featured_badges) do
    badges.select { |b| SiteSetting.custom_post_display_badge_ids.split(',').map(&:to_i).include?(b.id) }.uniq
  end
end
