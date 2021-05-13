import { ajax } from "discourse/lib/ajax";
import { withPluginApi } from "discourse/lib/plugin-api";
import { iconHTML } from "discourse-common/lib/icon-library";
import { schedule } from "@ember/runloop";
import { makeArray } from "discourse-common/lib/helpers";
import { helperContext } from "discourse-common/lib/helpers";
const { iconNode } = require("discourse-common/lib/icon-library");

export default {
  name: "discourse-custom-post-display-plugin",

  initialize() {
    withPluginApi("0.8.25", (api) => {
      api.includePostAttributes('user_post_count', 'user_likes_received', 'user_join_date', 'user_badges');

      api.decorateWidget("poster-name:after", helper => {
        var badgeEls = [];
        if (typeof helper.attrs.user_badges !== 'undefined') {
          helper.attrs.user_badges.forEach(function(badge) {
            badgeEls.push(
              helper.h(
                'span',
                { className: `cpd-badge cpd-badge-${badge.id} cpd-badge-${badge.slug}` },
                helper.h(
                  'a',
                  {
                    href: `/badges/${badge.id}/${badge.slug}`,
                    title: badge.name
                  },
                  iconNode(badge.icon)
                )
              )
            );
          });
        }
        const els = [
          iconNode('far-calendar-alt', {'class': 'cpd-join-date-icon'}),
          helper.h('span', { className: 'cpd-text cpd-join-date' }, '' + helper.attrs.user_join_date),
          iconNode('edit', {'class': 'cpd-post-count-icon'}),
          helper.h('span', { className: 'cpd-text cpd-post-count' }, '' + helper.attrs.user_post_count),
          iconNode('far-thumbs-up', {'class': 'cpd-likes-received-icon'}),
          helper.h('span', { className: 'cpd-text cpd-likes-received' }, '' + helper.attrs.user_likes_received),
        ];
        return helper.h(
          "div.cpd-container",
          {},
          helper.h('span',
            badgeEls.concat(els)
          )
        );
      });
    });
  },
};
