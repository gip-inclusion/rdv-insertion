describe AgentSessionFactory do
  describe ".create_with" do
    context "when not inclusion connected" do
      let!(:agent_auth) do
        { id: 12_344, origin:, created_at: Time.zone.now.to_i, signature: "ZEASADASDA" }
      end

      context "when the origin is sign_in_form" do
        let!(:origin) { "sign_in_form" }
        let!(:sign_in_form_session) { instance_double(AgentSession::ThroughSignInForm) }

        before do
          allow(AgentSession::ThroughSignInForm).to receive(:new)
            .with(**agent_auth).and_return(sign_in_form_session)
        end

        it "returns an instance of session through sign in form" do
          expect(described_class.create_with(**agent_auth)).to eq(sign_in_form_session)
        end
      end

      context "when the origin is impersonate" do
        let!(:origin) { "impersonate" }
        let!(:impersonate_session) { instance_double(AgentSession::ThroughImpersonate) }

        before do
          allow(AgentSession::ThroughImpersonate).to receive(:new)
            .with(**agent_auth).and_return(impersonate_session)
        end

        it "returns an instance of session through impersonate" do
          expect(described_class.create_with(**agent_auth)).to eq(impersonate_session)
        end
      end

      context "when the origin is none of the above" do
        let!(:origin) { nil }

        it "returns nothing" do
          expect(described_class.create_with(**agent_auth)).to be_nil
        end
      end
    end
  end
end
