require "rails_helper"

RSpec.describe UserListUpload::Sorter do
  describe ".custom_sort?" do
    it "returns true for attributes with custom sorting configuration" do
      expect(described_class.send(:custom_sort?, "before_user_save_status")).to be true
    end

    it "returns false for attributes without custom sorting configuration" do
      expect(described_class.send(:custom_sort?, "first_name")).to be false
    end
  end

  describe ".order_for" do
    it "returns cycle1 order for before_user_save_status with 'asc' direction" do
      expected_order = described_class::STATUS_ORDERS[:before_user_save_status][:cycle1]
      expect(described_class.send(:order_for, "before_user_save_status", "asc")).to eq(expected_order)
    end

    it "returns cycle2 order for before_user_save_status with 'desc' direction" do
      expected_order = described_class::STATUS_ORDERS[:before_user_save_status][:cycle2]
      expect(described_class.send(:order_for, "before_user_save_status", "desc")).to eq(expected_order)
    end
  end

  describe ".sort" do
    context "with standard attributes" do
      let(:user_row1) { instance_double("UserListUpload::UserRow", first_name: "John") }
      let(:user_row2) { instance_double("UserListUpload::UserRow", first_name: "Alice") }
      let(:user_row3) { instance_double("UserListUpload::UserRow", first_name: "Zoe") }
      let(:user_row_nil) { instance_double("UserListUpload::UserRow", first_name: nil) }

      let(:mixed_rows) { [user_row1, user_row2, user_row3, user_row_nil] }

      it "sorts standard attributes in ascending order" do
        sorted_rows = described_class.sort(mixed_rows, "first_name", "asc")
        expected_names = ["Alice", "John", "Zoe", nil]
        expect(sorted_rows.map(&:first_name)).to eq(expected_names)
      end

      it "sorts standard attributes in descending order" do
        sorted_rows = described_class.sort(mixed_rows, "first_name", "desc")
        expected_names = [nil, "Zoe", "John", "Alice"]
        expect(sorted_rows.map(&:first_name)).to eq(expected_names)
      end
    end

    context "with custom sort attributes" do
      let(:to_create_with_errors) do
        instance_double("UserListUpload::UserRow", before_user_save_status: :to_create_with_errors)
      end
      let(:to_create_with_no_errors) do
        instance_double("UserListUpload::UserRow", before_user_save_status: :to_create_with_no_errors)
      end
      let(:to_update_with_errors) do
        instance_double("UserListUpload::UserRow", before_user_save_status: :to_update_with_errors)
      end
      let(:to_update_with_no_errors) do
        instance_double("UserListUpload::UserRow", before_user_save_status: :to_update_with_no_errors)
      end
      let(:up_to_date) { instance_double("UserListUpload::UserRow", before_user_save_status: :up_to_date) }

      let(:mixed_rows) do
        [
          up_to_date,
          to_update_with_no_errors,
          to_create_with_errors,
          to_update_with_errors,
          to_create_with_no_errors
        ]
      end

      context "with sort_direction = 'asc' (cycle 1)" do
        it "sorts rows in the order: create errors, create no errors, update errors, update no errors, up to date" do
          sorted_rows = described_class.sort(mixed_rows, "before_user_save_status", "asc")

          expected_statuses = [
            :to_create_with_errors,
            :to_create_with_no_errors,
            :to_update_with_errors,
            :to_update_with_no_errors,
            :up_to_date
          ]

          expect(sorted_rows.map(&:before_user_save_status)).to eq(expected_statuses)
        end
      end

      context "with sort_direction = 'desc' (cycle 2)" do
        it "sorts rows in the order: update errors, update no errors, create errors, create no errors, up to date" do
          sorted_rows = described_class.sort(mixed_rows, "before_user_save_status", "desc")

          expected_statuses = [
            :to_update_with_errors,
            :to_update_with_no_errors,
            :to_create_with_errors,
            :to_create_with_no_errors,
            :up_to_date
          ]

          expect(sorted_rows.map(&:before_user_save_status)).to eq(expected_statuses)
        end
      end
    end
  end
end
