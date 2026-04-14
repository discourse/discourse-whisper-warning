import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import concatClass from "discourse/helpers/concat-class";
import { i18n } from "discourse-i18n";

export default class WhisperWarning extends Component {
  @service currentUser;
  @service composer;

  get showWarning() {
    const model = this.args.outletArgs.model;
    const composerAction = model.get("action");

    if (
      !this.composer.showWhisperToggle ||
      composerAction === "createTopic" ||
      composerAction === "createSharedDraft"
    ) {
      return false;
    }

    // Block new PMs (but allow replies to existing PMs)
    if (composerAction === "privateMessage") {
      return false;
    }

    if (!this.isInAllowedGroup) {
      return false;
    }

    if (settings.whisper_only && !this.composer.isWhispering) {
      return false;
    }

    return this.matchesContext;
  }

  // At least one context filter must match. If no context filters are
  // configured, show everywhere.
  get matchesContext() {
    const hasAnyContextFilter =
      settings.show_in_read_restricted_categories ||
      settings.show_in_group_pms ||
      this.parseListSetting(settings.restrict_to_categories).length > 0;

    if (!hasAnyContextFilter) {
      return true;
    }

    if (settings.show_in_read_restricted_categories && this.isReadRestricted) {
      return true;
    }

    if (settings.show_in_group_pms && this.isGroupPMWithUser) {
      return true;
    }

    if (this.isInExplicitCategoryList) {
      return true;
    }

    return false;
  }

  get isReadRestricted() {
    return !!this.args.outletArgs.model.category?.get("read_restricted");
  }

  get isGroupPMWithUser() {
    const topic = this.args.outletArgs.model.topic;
    if (topic?.get("archetype") !== "private_message") {
      return false;
    }

    const allowedGroups = topic.get("allowedGroups");
    if (!allowedGroups) {
      return false;
    }

    const userGroups = this.currentUser.groups ?? [];
    return allowedGroups.some((ag) =>
      userGroups.some((ug) => ug.name === ag.name)
    );
  }

  // Returns true if restrict_to_groups is empty, or the current user is a
  // member of at least one specified group. Matches by both group ID and name
  // to handle either storage format from the list_type: group setting.
  get isInAllowedGroup() {
    const groups = this.parseListSetting(settings.restrict_to_groups);

    if (groups.length === 0) {
      return true;
    }

    const userGroups = this.currentUser.groups ?? [];
    return groups.some((g) => {
      const asId = Number.parseInt(g, 10);
      return userGroups.some(
        (ug) =>
          ug.name.toLowerCase() === g.toLowerCase() ||
          (!Number.isNaN(asId) && ug.id === asId)
      );
    });
  }

  // Returns true if the current topic's category is in the explicit
  // restrict_to_categories list. Matches by both category ID and slug.
  get isInExplicitCategoryList() {
    const categories = this.parseListSetting(settings.restrict_to_categories);

    if (categories.length === 0) {
      return false;
    }

    const category = this.args.outletArgs.model.category;
    if (!category) {
      return false;
    }

    const catId = category.get ? category.get("id") : category.id;
    const catSlug = category.get ? category.get("slug") : category.slug;

    return categories.some((c) => {
      const asId = Number.parseInt(c, 10);
      return (
        (catSlug && catSlug.toLowerCase() === c.toLowerCase()) ||
        (!Number.isNaN(asId) && catId === asId)
      );
    });
  }

  // Normalises a list setting value to a trimmed, non-empty string array.
  parseListSetting(value) {
    return (Array.isArray(value) ? value : (value?.split(",") ?? []))
      .map((v) => String(v).trim())
      .filter(Boolean);
  }

  get icon() {
    return this.composer.isWhispering ? "far-eye-slash" : "far-eye";
  }

  get translatedLabel() {
    if (this.composer.isWhispering) {
      return i18n(themePrefix("whispering"));
    } else {
      return i18n(themePrefix("public_reply"));
    }
  }

  @action
  toggleWhisper() {
    this.composer.toggleWhisper();
  }

  <template>
    {{#if this.showWarning}}
      <DButton
        @preventFocus={{true}}
        @action={{this.toggleWhisper}}
        @icon={{this.icon}}
        class={{concatClass
          "whisper-hint"
          (if this.composer.isWhispering "whispering" "public")
        }}
        @translatedLabel={{this.translatedLabel}}
      />
    {{/if}}
  </template>
}
