import Component from "@glimmer/component";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { withPluginApi } from "discourse/lib/plugin-api";

class CustomPostDisplay extends Component {
  @service siteSettings;

  get badges() {
    return this.args.post?.user_badges || [];
  }

  get joinDate() {
    return this.args.post?.user_join_date;
  }

  get postCount() {
    return (
      (this.args.post?.user_post_count || 0) +
      (this.args.post?.user_topic_count || 0)
    );
  }

  get likesReceived() {
    return this.args.post?.user_likes_received || 0;
  }

  get helpUrl() {
    return this.siteSettings.custom_post_display_help_url;
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
      api.renderAfterWrapperOutlet(
        "post-meta-data-poster-name",
        CustomPostDisplay
      );
    });
  },
};
