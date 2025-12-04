describe MatomoHelper do
  describe "#matomo_page_url" do
    let(:mock_request) { instance_double(ActionDispatch::Request) }

    before do
      allow(helper).to receive(:request).and_return(mock_request)
    end

    def test_url_rewriting(path, expected_pattern)
      allow(mock_request).to receive(:path).and_return(path)
      expect(helper.matomo_page_url).to eq(expected_pattern)
    end

    it "rewrites organisation IDs to route pattern" do
      test_url_rewriting("/organisations/123/show_info", "/organisations/:id/show_info")
    end

    it "rewrites nested organisation and user IDs to route pattern" do
      test_url_rewriting("/organisations/123/users/456", "/organisations/:organisation_id/users/:id")
    end

    it "rewrites IDs and preserves follow_ups path" do
      test_url_rewriting(
        "/organisations/123/users/456/follow_ups",
        "/organisations/:organisation_id/users/:user_id/follow_ups"
      )
    end

    it "rewrites department and user IDs to route pattern" do
      test_url_rewriting("/departments/75/users/123", "/departments/:department_id/users/:id")
    end

    it "rewrites user_list_upload IDs to route pattern" do
      test_url_rewriting("/user_list_uploads/abc-123-def-456", "/user_list_uploads/:id")
    end

    it "rewrites invitation shortcut UUIDs to route pattern" do
      test_url_rewriting("/r/abc-123-def-456", "/r/:uuid")
    end

    it "keeps stats URLs unchanged" do
      test_url_rewriting("/stats", "/stats")
    end

    it "returns original path when route cannot be recognized" do
      test_url_rewriting("/non-existent-route", "/non-existent-route")
    end
  end
end
