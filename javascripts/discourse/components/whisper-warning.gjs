import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import concatClass from "discourse/helpers/concat-class";
import I18n from "discourse-common/helpers/i18n";

export default class WhisperWarning extends Component {
  @service currentUser;
  @service composer;

  get showWarning() {
    // checks if the current user is replying in a group PM
    const allowedGroups =
      this.args.outletArgs.model.topic?.get("allowedGroups");
    // to check if reply is in a PM
    const isPM =
      this.args.outletArgs.model.topic?.get("archetype") === "private_message";
    // checks to make sure user is in group that PM is added to
    const isInInboxGroup = allowedGroups
      ? this.currentUser.groups?.filter((group) => {
          for (let allowedGroup of allowedGroups) {
            if (group.name === allowedGroup.name) {
              return group;
            }
          }
        }).length > 0
      : false;

    const readRestricted =
      this.args.outletArgs.model.category?.get("read_restricted");
    const isWhisperWarningGroupMember =
      this.currentUser.groups?.filter((group) => {
        return group.name === "accidentalloudmouths";
      }).length > 0;
    const canWhisper = this.composer.showWhisperToggle;
    const isNotNewTopic =
      this.args.outletArgs.model.get("action") !== "createTopic";
    const isNotNewPM =
      this.args.outletArgs.model.get("action") !== "privateMessage";
    const isNotSharedDraft =
      this.args.outletArgs.model.get("action") !== "createSharedDraft";

    return (
      (canWhisper &&
        isNotNewTopic &&
        isNotNewPM &&
        isNotSharedDraft &&
        isWhisperWarningGroupMember &&
        readRestricted) ||
      (isPM && isInInboxGroup && canWhisper && isWhisperWarningGroupMember)
    );
  }

  get whisperLabel() {
    return I18n.t(themePrefix("whispering"));
  }

  get publicLabel() {
    return I18n.t(themePrefix("public_reply"));
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
        @icon="far-eye-slash"
        @class={{concatClass
          "whisper-hint"
          (if this.composer.isWhispering "whispering" "public")
        }}
        @translatedLabel={{(if
          this.composer.isWhispering this.whisperLabel this.publicLabel
        )}}
      />
    {{/if}}
  </template>
}
