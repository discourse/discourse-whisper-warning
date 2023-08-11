import Component from "@glimmer/component";
import { inject as service } from "@ember/service";

export default class WhisperWarning extends Component {
  @service currentUser;

  get shouldRender() {
    console.log(this.args.outletArgs.model);
    const canWhisper = this.currentUser.whisperer;
    const isNotNewTopic = this.args.outletArgs.model.get("action") !== "createTopic";
    const isNotNewPM = this.args.outletArgs.model.get("action") !== "privateMessage";
    const isNotSharedDraft = this.args.outletArgs.model.get("action") !== "createSharedDraft";

    return canWhisper && isNotNewTopic && isNotNewPM && isNotSharedDraft;
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
