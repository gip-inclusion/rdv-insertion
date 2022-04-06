describe RdvContext do
  describe "#action_required" do
    subject { described_class.action_required }

    context "when status requires action" do
      let!(:rdv_context) { create(:rdv_context, status: "rdv_noshow") }

      it "retrieves the rdv_context" do
        expect(subject).to include(rdv_context)
      end
    end

    context "when status does not require action nor attention" do
      let!(:rdv_context) { create(:rdv_context, status: "rdv_seen") }

      it "does not retrieve the rdv_context" do
        expect(subject).not_to include(rdv_context)
      end
    end

    context "when status needs attention" do
      let!(:rdv_context) { create(:rdv_context, status: "invitation_pending") }

      context "when the rdv_context has been last invited less than 3 days ago" do
        let!(:invitation) { create(:invitation, rdv_context: rdv_context, sent_at: 2.hours.ago) }

        it "does not retrieve the rdv_context" do
          expect(subject).not_to include(rdv_context)
        end
      end

      context "when the rdv_context has been invited more than 3 days ago" do
        let!(:invitation) { create(:invitation, rdv_context: rdv_context, sent_at: 5.days.ago) }

        it "does not retrieve the rdv_context" do
          expect(subject).to include(rdv_context)
        end
      end
    end
  end

  describe "#set_status" do
    subject { rdv_context.set_status }

    context "without rdvs" do
      context "without invitations or rdvs" do
        let!(:rdv_context) { create(:rdv_context, rdvs: [], invitations: []) }

        it "is not invited" do
          expect(subject).to eq(:not_invited)
        end
      end

      context "with no sent invitation" do
        let!(:invitation) { create(:invitation, sent_at: nil, rdv_context: rdv_context) }
        let!(:rdv_context) { create(:rdv_context, rdvs: []) }

        it "is not invited" do
          expect(subject).to eq(:not_invited)
        end
      end

      context "with sent invitation" do
        let!(:invitation) { create(:invitation, sent_at: 2.days.ago) }
        let!(:rdv_context) { create(:rdv_context, invitations: [invitation]) }

        context "with no rdvs" do
          it "is in invitation pending" do
            expect(subject).to eq(:invitation_pending)
          end
        end

        context "when the invitation has been sent after last rdv" do
          let!(:rdv) { create(:rdv, status: "seen", starts_at: 3.days.ago, rdv_contexts: [rdv_context]) }

          it "is in invitation pending" do
            expect(subject).to eq(:invitation_pending)
          end
        end

        context "when the rdv has starts after the invitation" do
          let!(:rdv) { create(:rdv, status: "seen", starts_at: 1.day.ago, rdv_contexts: [rdv_context]) }

          it "is the status of the rdv" do
            expect(subject).to eq(:rdv_seen)
          end
        end
      end
    end

    context "with rdvs" do
      context "with a seen rdv" do
        let!(:rdv) { create(:rdv, status: "seen", starts_at: 4.days.ago) }
        let!(:rdv2) { create(:rdv, status: "noshow", starts_at: 2.days.ago) }
        let!(:rdv_context) { create(:rdv_context, rdvs: [rdv, rdv2]) }

        it "is the last rdv" do
          expect(subject).to eq(:rdv_noshow)
        end
      end

      context "with at least 2 rdvs cancelled" do
        let!(:rdv) { create(:rdv, status: "noshow") }
        let!(:rdv2) { create(:rdv, status: "excused") }
        let!(:rdv_context) { create(:rdv_context, rdvs: [rdv, rdv2]) }

        it "is mutliple rdvs cancelled" do
          expect(subject).to eq(:multiple_rdvs_cancelled)
        end
      end

      context "with a past rdv with status not updated" do
        let!(:rdv) { create(:rdv, status: "unknown", starts_at: 2.days.ago) }
        let!(:rdv_context) { create(:rdv_context, rdvs: [rdv]) }

        it "is rdv pending" do
          expect(subject).to eq(:rdv_needs_status_update)
        end
      end
    end
  end
end
