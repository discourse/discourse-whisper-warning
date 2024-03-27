import Component from "@glimmer/component";
import { service } from "@ember/service";
import I18n from "discourse-i18n";

export default class WhisperWarning extends Component {
  @service currentUser;

  get shouldRender() {
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
    const canWhisper = this.currentUser.whisperer;
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

  get isWhispering() {
    let whisper = this.args.outletArgs.model.get("whisper");
    return whisper;
  }

  get publicLabel() {
    return I18n.t(themePrefix("public_reply"));
  }

  get whisperLabel() {
    return I18n.t(themePrefix("whispering"));
  }
}
