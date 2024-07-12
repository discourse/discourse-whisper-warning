import { apiInitializer } from "discourse/lib/api";
import whisperWarning from "../components/whisper-warning";

export default apiInitializer("1.8.0", (api) => {
  api.renderInOutlet("composer-action-after", whisperWarning);
});
