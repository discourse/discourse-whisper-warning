export default function migrate(settings) {
  if (
    settings.has("restrict_to_groups") &&
    !String(settings.get("restrict_to_groups") ?? "").trim()
  ) {
    settings.set("restrict_to_groups", "1|2");
  }

  return settings;
}
