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

  # Fix 1: Add respect_plugin_enabled as a keyword argument
  add_to_serializer(:post, :user_post_count, false, respect_plugin_enabled: true) do
    object&.user&.post_count || 0
  end

  # Fix 2: Add respect_plugin_enabled as a keyword argument
  add_to_serializer(:post, :user_topic_count, false, respect_plugin_enabled: true) do
    object&.user&.topic_count || 0
  end

  # Fix 3: Add respect_plugin_enabled as a keyword argument
  add_to_serializer(:post, :user_likes_received, false, respect_plugin_enabled: true) do
    object&.user&.user_stat&.likes_received || 0
  end

  # Fix 4: Add respect_plugin_enabled as a keyword argument
  add_to_serializer(:post, :user_join_date, false, respect_plugin_enabled: true) do
    "#{object&.user&.created_at&.strftime(SiteSetting.custom_post_display_join_format)}" || "unknown" rescue "bad fmt"
  end

  # Fix 5: Replace direct include_*? method with include_condition keyword argument
  # Instead of:
  # add_to_serializer(:post, :include_user_post_count?) do
  #   SiteSetting.custom_post_display_enabled
  # end
  # Use:
  add_to_serializer(:post, :user_post_count, false, 
    include_condition: -> { SiteSetting.custom_post_display_enabled },
    respect_plugin_enabled: true)

  add_to_serializer(:post, :user_topic_count, false, 
    include_condition: -> { SiteSetting.custom_post_display_enabled },
    respect_plugin_enabled: true)

  add_to_serializer(:post, :user_likes_received, false, 
    include_condition: -> { SiteSetting.custom_post_display_enabled },
    respect_plugin_enabled: true)

  add_to_serializer(:post, :user_join_date, false, 
    include_condition: -> { SiteSetting.custom_post_display_enabled },
    respect_plugin_enabled: true)

  add_to_serializer(:user, :badges) do
    badges = []
  end
end
