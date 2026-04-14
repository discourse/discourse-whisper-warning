# frozen_string_literal: true

RSpec.describe "Whisper Warning" do
  fab!(:admin)
  fab!(:moderator)
  fab!(:group)
  fab!(:category)
  fab!(:read_restricted_category) { Fabricate(:private_category, group: Group[:staff]) }
  fab!(:topic) do
    Fabricate(:post, topic: Fabricate(:topic, category: read_restricted_category)).topic
  end

  let!(:theme) { upload_theme_or_component }

  before do
    SiteSetting.whispers_allowed_groups = "#{Group::AUTO_GROUPS[:staff]}"
    group.add(moderator)
    sign_in(moderator)
  end

  def open_composer_for(t = topic)
    visit "/t/#{t.slug}/#{t.id}"
    find("#topic-footer-buttons .create").click
    expect(page).to have_css("#reply-control")
  end

  def enable_whisper
    find(".composer-actions").click
    find("[data-value='toggle_whisper']").click
  end

  context "with default settings" do
    it "shows the warning in a read-restricted category" do
      open_composer_for
      expect(page).to have_css(".whisper-hint")
    end

    it "hides the warning in a public category" do
      public_topic = Fabricate(:post, topic: Fabricate(:topic, category: category)).topic
      open_composer_for(public_topic)
      expect(page).not_to have_css(".whisper-hint")
    end

    it "shows the public class when not whispering" do
      open_composer_for
      expect(page).to have_css(".whisper-hint.public")
    end

    it "shows the whispering class when whispering" do
      open_composer_for
      enable_whisper
      expect(page).to have_css(".whisper-hint.whispering")
    end
  end

  context "with show_in_read_restricted_categories disabled but an explicit category set" do
    before do
      theme.update_setting(:show_in_read_restricted_categories, false)
      theme.update_setting(:show_in_group_pms, false)
      theme.update_setting(:restrict_to_categories, category.slug)
      theme.save!
    end

    it "does not auto-show in a read-restricted category" do
      open_composer_for
      expect(page).not_to have_css(".whisper-hint")
    end

    it "still shows in the explicitly listed category" do
      public_topic = Fabricate(:post, topic: Fabricate(:topic, category: category)).topic
      open_composer_for(public_topic)
      expect(page).to have_css(".whisper-hint")
    end
  end

  context "with all context filters off" do
    before do
      theme.update_setting(:show_in_read_restricted_categories, false)
      theme.update_setting(:show_in_group_pms, false)
      theme.save!
    end

    it "shows everywhere as a fallback" do
      public_topic = Fabricate(:post, topic: Fabricate(:topic, category: category)).topic
      open_composer_for(public_topic)
      expect(page).to have_css(".whisper-hint")
    end
  end

  context "with whisper_only enabled" do
    before do
      theme.update_setting(:whisper_only, true)
      theme.save!
    end

    it "hides the button when composing a public reply" do
      open_composer_for
      expect(page).not_to have_css(".whisper-hint")
    end

    it "shows the button when composing a whisper" do
      open_composer_for
      enable_whisper
      expect(page).to have_css(".whisper-hint.whispering")
    end
  end

  context "with restrict_to_groups set" do
    before do
      theme.update_setting(:restrict_to_groups, group.name)
      theme.save!
    end

    it "shows for users in the specified group" do
      open_composer_for
      expect(page).to have_css(".whisper-hint")
    end

    it "hides for users not in the specified group" do
      sign_in(admin)
      open_composer_for
      expect(page).not_to have_css(".whisper-hint")
    end
  end

  context "with restrict_to_categories set" do
    fab!(:extra_category, :category)
    fab!(:extra_topic) do
      Fabricate(:post, topic: Fabricate(:topic, category: extra_category)).topic
    end
    fab!(:other_topic) { Fabricate(:post).topic }

    before do
      theme.update_setting(:restrict_to_categories, extra_category.slug)
      theme.save!
    end

    it "shows when replying in a category from the explicit list" do
      open_composer_for(extra_topic)
      expect(page).to have_css(".whisper-hint")
    end

    it "also shows in read-restricted categories by default" do
      open_composer_for
      expect(page).to have_css(".whisper-hint")
    end

    it "hides when replying in an unlisted public category" do
      open_composer_for(other_topic)
      expect(page).not_to have_css(".whisper-hint")
    end
  end
end
