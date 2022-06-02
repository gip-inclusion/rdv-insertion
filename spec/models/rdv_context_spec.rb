describe RdvContext do
  describe "#action_required" do
    subject { described_class.action_required(number_of_days_before_action_required) }

    let!(:number_of_days_before_action_required) { 3 }

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

      context "when the rdv_context has been invited less than 3 days ago" do
        let!(:invitation) { create(:invitation, rdv_context: rdv_context, sent_at: 2.hours.ago) }

        it "does not retrieve the rdv_context" do
          expect(subject).not_to include(rdv_context)
        end
      end

      context "when the rdv_context has been first invited more than 3 days ago" do
        let!(:invitation) { create(:invitation, rdv_context: rdv_context, sent_at: 5.days.ago) }
        let!(:invitation2) { create(:invitation, rdv_context: rdv_context, sent_at: 2.hours.ago) }

        it "retrieve the rdv_context" do
          expect(subject).to include(rdv_context)
        end
      end

      context "when the rdv_context has been invited more than 3 days ago" do
        let!(:invitation) { create(:invitation, rdv_context: rdv_context, sent_at: 5.days.ago) }

        it "retrieves the rdv_context" do
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

    describe "#invited_before_time_window?" do
      let!(:number_of_days_before_action_required) { 3 }

      context "when no rdv seen or status is rdv_seen" do
        let!(:invitation) { create(:invitation, sent_at: 2.days.ago) }
        let!(:invitation2) { create(:invitation, sent_at: 1.day.ago) }
        let!(:rdv_context) { create(:rdv_context, invitations: [invitation, invitation2]) }

        context "when invited in time window" do
          it "is false" do
            expect(rdv_context.invited_before_time_window?(number_of_days_before_action_required)).to eq(false)
          end
        end

        context "when not invited in time window" do
          let!(:invitation) { create(:invitation, sent_at: 6.days.ago) }

          it "is true" do
            expect(rdv_context.invited_before_time_window?(number_of_days_before_action_required)).to eq(true)
          end
        end
      end

      context "when there is a rdv_seen but status is not rdv_seen" do
        let!(:rdv) { create(:rdv, status: "seen", starts_at: 4.days.ago) }
        let!(:invitation) { create(:invitation, sent_at: 6.days.ago) }
        let!(:invitation2) { create(:invitation, sent_at: 2.days.ago) }
        let!(:invitation3) { create(:invitation, sent_at: 1.day.ago) }
        let!(:rdv_context) do
          create(:rdv_context, status: "invitation_pending",
                               rdvs: [rdv], invitations: [invitation, invitation2, invitation3])
        end

        context "first_current_invitation_sent_at" do
          it "is selecting the right invitation" do
            expect(rdv_context.first_current_invitation_sent_at).to eq(invitation2.sent_at)
          end
        end

        context "when invited in time window" do
          it "is false" do
            expect(rdv_context.invited_before_time_window?(number_of_days_before_action_required)).to eq(false)
          end
        end

        context "when not invited in time window" do
          let!(:invitation2) { create(:invitation, sent_at: 4.days.ago) }

          it "is true" do
            expect(rdv_context.invited_before_time_window?(number_of_days_before_action_required)).to eq(true)
          end
        end
      end
    end
  end
end
