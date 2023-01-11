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

      context "when the applicant has been invited less than 3 days ago in this context" do
        let!(:invitation) { create(:invitation, rdv_context: rdv_context, sent_at: 2.hours.ago) }

        it "does not retrieve the rdv_context" do
          expect(subject).not_to include(rdv_context)
        end
      end

      context "when the applicant has been first invited more than 3 days ago in this context" do
        let!(:invitation) { create(:invitation, rdv_context: rdv_context, sent_at: 5.days.ago) }
        let!(:invitation2) { create(:invitation, rdv_context: rdv_context, sent_at: 2.hours.ago) }

        it "retrieve the rdv_context" do
          expect(subject).to include(rdv_context)
        end
      end

      context "when the applicant has been invited more than 3 days ago in this context" do
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
        let!(:applicant) { create(:applicant) }
        let!(:invitation) { create(:invitation, sent_at: 2.days.ago, applicant: applicant) }
        let!(:rdv_context) { create(:rdv_context, applicant: applicant, invitations: [invitation]) }

        context "with no rdvs" do
          it "is in invitation pending" do
            expect(subject).to eq(:invitation_pending)
          end
        end

        context "with a seen rdv" do
          context "when the invitation has been sent after last rdv" do
            let!(:participation) do
              create(
                :participation,
                applicant: applicant,
                status: "seen",
                rdv_context: rdv_context
              )
            end
            let!(:rdv) do
              create(
                :rdv,
                starts_at: 3.days.ago,
                participations: [participation]
              )
            end

            it "is in invitation pending" do
              expect(subject).to eq(:invitation_pending)
            end
          end

          context "when the rdv has starts after the invitation" do
            let!(:participation) do
              create(
                :participation,
                applicant: applicant,
                status: "seen",
                rdv_context: rdv_context
              )
            end
            let!(:rdv) do
              create(
                :rdv,
                starts_at: 1.day.ago,
                participations: [participation]
              )
            end

            it "is the status of the rdv" do
              expect(subject).to eq(:rdv_seen)
            end
          end
        end

        context "when a rdv is pending" do
          let!(:participation) do
            create(
              :participation,
              applicant: applicant,
              status: "unknown",
              rdv_context: rdv_context
            )
          end
          let!(:rdv) do
            create(
              :rdv,
              starts_at: 1.day.from_now,
              created_at: 4.days.ago,
              participations: [participation]
            )
          end

          it "is the status of the rdv" do
            expect(subject).to eq(:rdv_pending)
          end
        end

        context "with a cancelled rdv" do
          context "when the invitation has been sent after the rdv creation" do
            let!(:participation) do
              create(
                :participation,
                applicant: applicant,
                status: "noshow",
                rdv_context: rdv_context
              )
            end
            let!(:rdv) do
              create(
                :rdv,
                starts_at: 4.days.from_now,
                created_at: 4.days.ago,
                participations: [participation]
              )
            end

            it "is in invitation pending" do
              expect(subject).to eq(:invitation_pending)
            end
          end

          context "when the invitation has been sent before the rdv creation" do
            let!(:participation) do
              create(
                :participation,
                applicant: applicant,
                status: "noshow",
                rdv_context: rdv_context
              )
            end
            let!(:rdv) do
              create(
                :rdv,
                starts_at: 4.days.from_now,
                created_at: 1.day.ago,
                participations: [participation]
              )
            end

            it "is the status of the rdv" do
              expect(subject).to eq(:rdv_noshow)
            end
          end
        end

        context "with mutliple rdvs after invitation" do
          let!(:invitation) { create(:invitation, sent_at: 10.days.ago) }
          let!(:participation) do
            create(
              :participation,
              applicant: applicant,
              status: "seen",
              rdv_context: rdv_context
            )
          end
          let!(:rdv) do
            create(
              :rdv,
              created_at: 4.days.ago,
              starts_at: 4.days.ago,
              participations: [participation]
            )
          end

          let!(:participation2) do
            create(
              :participation,
              applicant: applicant,
              status: "noshow",
              rdv_context: rdv_context
            )
          end
          let!(:rdv2) do
            create(
              :rdv,
              created_at: 5.days.ago,
              starts_at: 2.days.ago,
              participations: [participation2]
            )
          end

          it "is the status of the last created rdv" do
            expect(subject).to eq(:rdv_seen)
          end

          context "when a rdv is pending" do
            let!(:participation) do
              create(
                :participation,
                applicant: applicant,
                status: "unknown",
                rdv_context: rdv_context
              )
            end
            let!(:rdv3) do
              create(
                :rdv,
                created_at: 8.days.ago,
                starts_at: 2.days.from_now,
                participations: [participation]
              )
            end

            it "is rdv_pending" do
              expect(subject).to eq(:rdv_pending)
            end
          end

          context "when the last rdv is cancelled and one other has been cancelled" do
            let!(:participation) do
              create(
                :participation,
                applicant: applicant,
                status: "excused",
                rdv_context: rdv_context
              )
            end
            let!(:rdv3) do
              create(
                :rdv,
                created_at: 1.day.ago,
                participations: [participation]
              )
            end

            it "is mutliple rdvs cancelled" do
              expect(subject).to eq(:multiple_rdvs_cancelled)
            end
          end

          context "when the last rdv already took place but the status is not updated" do
            let!(:participation) do
              create(
                :participation,
                applicant: applicant,
                status: "unknown",
                rdv_context: rdv_context
              )
            end
            let!(:rdv3) do
              create(
                :rdv,
                created_at: 1.day.ago,
                starts_at: 2.days.ago,
                participations: [participation]
              )
            end

            it "is needs status update" do
              expect(subject).to eq(:rdv_needs_status_update)
            end
          end
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
        let!(:rdv) { create(:rdv, starts_at: 4.days.ago, participations: [participation]) }
        let!(:applicant) { create(:applicant) }
        let!(:participation) do
          create(
            :participation,
            applicant: applicant,
            status: "seen",
            rdv_context: rdv_context
          )
        end
        let!(:invitation) { create(:invitation, sent_at: 6.days.ago) }
        let!(:invitation2) { create(:invitation, sent_at: 2.days.ago) }
        let!(:invitation3) { create(:invitation, sent_at: 1.day.ago) }
        let!(:rdv_context) do
          create(:rdv_context, status: "invitation_pending", applicant: applicant,
                               invitations: [invitation, invitation2, invitation3])
        end

        context "first_sent_invitation_after_last_seen_rdv" do
          it "is selecting the right invitation" do
            expect(rdv_context.first_sent_invitation_after_last_seen_rdv_sent_at).to eq(invitation2.sent_at)
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
