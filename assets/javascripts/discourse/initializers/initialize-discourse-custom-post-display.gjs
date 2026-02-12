import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import icon from "discourse/helpers/d-icon";
import { withPluginApi } from "discourse/lib/plugin-api";

class CustomPostDisplay extends Component {
  @service siteSettings;

  @tracked _postCount = null;
  @tracked _likesReceived = null;
  @tracked _joinDate = null;
  @tracked _badges = null;
  @tracked _loaded = false;

  get post() {
    return this.args.post;
  }

  get badges() {
    if (this._badges !== null) {
      return this._badges;
    }
    return this.post?.user_badges || [];
  }

  get joinDate() {
    if (this._joinDate !== null) {
      return this._joinDate;
    }
    return this.post?.user_join_date || "";
  }

  get postCount() {
    if (this._postCount !== null) {
      return this._postCount;
    }
    const count =
      (this.post?.user_post_count || 0) +
      (this.post?.user_topic_count || 0);
    return count;
  }

  get likesReceived() {
    if (this._likesReceived !== null) {
      return this._likesReceived;
    }
    return this.post?.user_likes_received || 0;
  }

  get needsLoad() {
    if (this._loaded) {
      return false;
    }
    const post = this.post;
    if (!post) {
      return false;
    }
    const hasPostCount =
      post.user_post_count !== undefined && post.user_post_count !== null;
    const hasLikes =
      post.user_likes_received !== undefined &&
      post.user_likes_received !== null;
    const hasJoinDate =
      post.user_join_date !== undefined &&
      post.user_join_date !== null &&
      post.user_join_date !== "";
    return !hasPostCount || !hasLikes || !hasJoinDate;
  }

  get helpUrl() {
    const settingUrl = this.siteSettings.custom_post_display_help_url;
    if (settingUrl) {
      return settingUrl;
    }
    const username = this.post?.username;
    if (username) {
      return `/u/${username}/summary`;
    }
    return "";
  }

  constructor() {
    super(...arguments);
    this._maybeLoadData();
  }

  async _maybeLoadData() {
    if (!this.needsLoad) {
      return;
    }
    const post = this.post;
    if (!post?.id) {
      return;
    }
    try {
      const result = await ajax(`/posts/${post.id}.json`);
      if (result) {
        const userPostCount = result.user_post_count || 0;
        const userTopicCount = result.user_topic_count || 0;
        this._postCount = userPostCount + userTopicCount;
        this._likesReceived = result.user_likes_received || 0;
        if (result.user_join_date) {
          this._joinDate = result.user_join_date;
        }
        if (result.user_badges) {
          this._badges = result.user_badges;
        }
        this._loaded = true;
      }
    } catch (e) {
      // Silently fail - display will show 0 as fallback
    }
  }

  <template>
    <div class="cpd-container">
      <a href={{this.helpUrl}}>
        <span class="cpd-span">
          {{#each this.badges as |badge|}}
            <span
              class="cpd-badge cpd-badge-{{badge.id}} cpd-badge-{{badge.slug}}"
            >
              <a
                href="/badges/{{badge.id}}/{{badge.slug}}"
                title={{badge.name}}
              >
                {{icon badge.icon}}
              </a>
            </span>
          {{/each}}
          {{icon "calendar-days" class="cpd-join-date-icon"}}

          <span class="cpd-text cpd-join-date" title="Data de cadastro">
            {{this.joinDate}}
          </span>
          {{icon "pen-to-square" class="cpd-post-count-icon"}}
          <span class="cpd-text cpd-post-count" title="Publicações escritas">
            {{this.postCount}}
          </span>
          {{icon "heart" class="cpd-likes-received-icon"}}
          <span class="cpd-text cpd-likes-received" title="Reações recebidas">
            {{this.likesReceived}}
          </span>
        </span>
      </a>
    </div>
  </template>
}

export default {
  name: "discourse-custom-post-display-plugin",
  initialize() {
    withPluginApi((api) => {
      // Register custom serializer fields as tracked properties so the
      // Glimmer post stream includes them when posts arrive via MessageBus
      // and triggers reactive re-renders when their values change.
      api.addTrackedPostProperties(
        "user_post_count",
        "user_topic_count",
        "user_likes_received",
        "user_join_date",
        "user_badges"
      );

      api.renderAfterWrapperOutlet(
        "post-meta-data-poster-name",
        CustomPostDisplay
      );
    });
  },
};
