require "rails_helper"
require Rails.root.join("lib/chores/clean_duplicated_tags")

RSpec.describe Chores::CleanDuplicatedTags, type: :service do
  describe ".call" do
    let(:user) { create(:user) }
    let(:tag1) { create(:tag) }
    let(:tag2) { create(:tag) }

    context "when there are duplicate TagUser records" do
      before do
        TagUser.new(tag: tag1, user: user).save(validate: false)
        TagUser.new(tag: tag1, user: user).save(validate: false)
        TagUser.new(tag: tag2, user: user).save(validate: false)
        TagUser.new(tag: tag2, user: user).save(validate: false)
        TagUser.new(tag: tag2, user: user).save(validate: false)
      end

      it "removes duplicates and keeps the first record" do
        expect { described_class.call }.to change(TagUser, :count).by(-3)

        expect(TagUser.where(tag: tag1, user: user).count).to eq(1)
        expect(TagUser.where(tag: tag2, user: user).count).to eq(1)
      end
    end

    context "when there are no duplicates" do
      before do
        TagUser.new(tag: tag1, user: user).save(validate: false)
        TagUser.new(tag: tag2, user: user).save(validate: false)
      end

      it "does not remove any records" do
        expect { described_class.call }.not_to(change(TagUser, :count))
      end
    end
  end
end
