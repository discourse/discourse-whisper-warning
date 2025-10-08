import { apiInitializer } from "discourse/lib/api";
import whisperWarning from "../components/whisper-warning";

export default apiInitializer((api) => {
  api.renderInOutlet("composer-action-after", whisperWarning);
});
